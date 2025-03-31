module ChallongeApi
  extend ActiveSupport::Concern

  def export_team_to_challonge(team: nil)
    team = team || current_user.team
    players = team.players.where.not(player_type: "reserved_player")

    if  players.count == 2 && team.completed?

      # check existing challonge participant
      url = "#{challonge_host}/participants/#{team.participant_id}.json?api_key=#{ENV["API_KEY"]}"
      response = HTTParty.get(url)

      if response.code != 200

        # add participant to challonge
        team_name = team.name || "team_#{SecureRandom.random_number(10**2)}"
        url = "#{challonge_host}/participants.json?api_key=#{ENV["API_KEY"]}&participant[name]=#{team_name}"
        response = HTTParty.post(url)
        Rails.logger.info("---Participant Added to challonge---")
      end
      if response.code == 200
        team.update(participant_id: response["participant"]["id"], name: response["participant"]["name"], tournament_id: response["participant"]["tournament_id"])
      end
    end
  end

  def import_matches
    tournament_status = tournament_started
    if tournament_status[0]
      update_participants
      update_tournament(tournament_status[1])
      retrieve_matches
    end
  end

  def update_participants
    url = "#{challonge_host}/participants.json?api_key=#{ENV["API_KEY"]}"
    response = HTTParty.get(url)
    response.each do |participant|
      team = Team.find_by(participant_id: participant["participant"]["id"])
      team.update(group_player_ids:  participant["participant"]["group_player_ids"]) rescue nil
    end
  end

  def retrieve_matches
    url = "#{challonge_host}/matches.json?api_key=#{ENV["API_KEY"]}"
    response = HTTParty.get(url)
    response.each do |match_data|
      matchh = Match.find_or_create_by(match_id: match_data["match"]["id"])
      teams = Team.where('group_player_ids && ARRAY[?, ?]::integer[]', match_data["match"]["player1_id"], match_data["match"]["player2_id"])
      unless teams.pluck(:home).any?(true)
        teams.first.update(home: true) rescue nil
      end
      home_teams = teams.where(home: true)
      if home_teams.count > 1
        home_teams.last.update(home: false) rescue nil
      end
      home_course_id = matchh.home_course_id.present? ? matchh.home_course_id : teams&.first&.home_course&.id
      match_time = matchh.match_time.present? ? matchh.match_time : Time.now + 5.days
      matchh.update(match_params(match_data.merge({ home_course_id: , match_time: })))
      add_teams(matchh)
    end
  end

  def add_teams(matchh)
    teams = Team.where.not(participant_id: nil)
                      .where('group_player_ids && ARRAY[?, ?]::integer[]', matchh.player1_id.to_i, matchh.player2_id.to_i)
    existing_team_ids = matchh.teams.ids
    new_team_ids = teams.ids - existing_team_ids
    new_teams = Team.where(id: new_team_ids)
    matchh.teams << new_teams
  end

  def match_params(match_data)
    tournament_id = match_data["match"]["tournament_id"]
    round = match_data["match"]["round"]
    match_id = match_data["match"]["id"]
    player1_id = match_data["match"]["player1_id"]
    player2_id = match_data["match"]["player2_id"]
    winner_id = match_data["match"]["winner_id"]
    loser_id = match_data["match"]["loser_id"]
    suggested_player_order = match_data["match"]["suggested_player_order"]
    scores_csv = match_data["match"]["scores_csv"]
    {
      tournament_id: tournament_id,
      round: round,
      match_id: match_id,
      player1_id: player1_id,
      player2_id: player2_id,
      winner_id: winner_id,
      loser_id: loser_id,
      suggested_player_order: suggested_player_order,
      scores_csv: scores_csv,
      home_course_id: match_data[:home_course_id],
      match_time: match_data[:match_time]
    }
  end

  def update_tournament(response)
    tournament = Tournament.find_or_create_by(url: response["tournament"]["url"])

    tournament.update(
      response["tournament"].slice(
        "name", "tournament_type", "subdomain", "state", "description", "open_signup",
        "hold_third_place_match", "pts_for_match_win", "pts_for_match_tie",
        "pts_for_game_win", "pts_for_game_tie", "pts_for_bye", "swiss_rounds",
        "ranked_by", "accept_attachments", "hide_forum", "show_rounds",
        "private", "notify_users_when_matches_open",
        "notify_users_when_the_tournament_ends", "sequential_pairings",
        "signup_cap", "start_at", "check_in_duration", "grand_finals_modifier"
      )
    )
  end

  def tournament_started
    url = "#{challonge_host}.json?api_key=#{ENV["API_KEY"]}"
    response = HTTParty.get(url)
    if response["tournament"]["state"] == 'pending'
      Tournament.find_by(url: ENV['TOURNAMENT']).update(state: 'pending')
      Match.destroy_all
    end
    [(response["tournament"]["state"] != "pending"), response]
  end

  def process_elimination(match)
    team1 = match.teams.first
    team2 = match.teams.second
    
    team1_scores = HoleScore.where(match_id: match.id, user_id: team1.players.ids)
    score_1 = team1_scores.maximum(:score).to_i
    
    team2_scores = HoleScore.where(match_id: match.id, user_id: team2.players.ids)
    score_2 = team2_scores.maximum(:score).to_i
  
    if score_1 > score_2
      winner_id = team1.id
      loser_id = team2.id
    elsif score_2 > score_1
      winner_id = team2.id
      loser_id = team1.id
    elsif score_2 == score_1
      # Scorecard Playoff Logic
      # Get scores for the last 9 holes
      last_nine_holes = (match.home_course.holes_count - 9..match.home_course.holes_count - 1).to_a
      team1_back9_scores = team1_scores.where(hole_number: last_nine_holes)
      team2_back9_scores = team2_scores.where(hole_number: last_nine_holes)
  
      score_1_back9 = team1_back9_scores.sum(:score)
      score_2_back9 = team2_back9_scores.sum(:score)
  
      if score_1_back9 > score_2_back9
        winner_id = team1.id
        loser_id = team2.id
      elsif score_2_back9 > score_1_back9
        winner_id = team2.id
        loser_id = team1.id
      else
        # Check last 6 holes
        last_six_holes = (match.home_course.holes_count - 6..match.home_course.holes_count - 1).to_a
        team1_last6_scores = team1_scores.where(hole_number: last_six_holes)
        team2_last6_scores = team2_scores.where(hole_number: last_six_holes)
  
        score_1_last6 = team1_last6_scores.sum(:score)
        score_2_last6 = team2_last6_scores.sum(:score)
  
        if score_1_last6 > score_2_last6
          winner_id = team1.id
          loser_id = team2.id
        elsif score_2_last6 > score_1_last6
          winner_id = team2.id
          loser_id = team1.id
        else
          # Check last 3 holes
          last_three_holes = (match.home_course.holes_count - 3..match.home_course.holes_count - 1).to_a
          team1_last3_scores = team1_scores.where(hole_number: last_three_holes)
          team2_last3_scores = team2_scores.where(hole_number: last_three_holes)
  
          score_1_last3 = team1_last3_scores.sum(:score)
          score_2_last3 = team2_last3_scores.sum(:score)
  
          if score_1_last3 > score_2_last3
            winner_id = team1.id
            loser_id = team2.id
          elsif score_2_last3 > score_1_last3
            winner_id = team2.id
            loser_id = team1.id
          else
            # Flip a coin to determine the winner
            if [true, false].sample
              winner_id = team1.id
              loser_id = team2.id
            else
              winner_id = team2.id
              loser_id = team1.id
            end
          end
        end
      end
    end
  
    Team.find_by_id(winner_id)&.update_column(:disqualified, false)
    match.update(winner_id: winner_id, loser_id: loser_id)
    [match.winner_id, match.loser_id]
  end

  def submit_scores_csv
    scores = @match.scores_csv.max.split('-').map(&:to_i)
    team1 = Team.find_by(participant_id: @match.player1_id)
    team2 = Team.find_by(participant_id: @match.player2_id)
    if scores[1] > scores[0]
      winner_id = team2.participant_id
      loser_id = team1.participant_id
    elsif scores[0] > scores[1]
      winner_id = team1.participant_id
      loser_id = team2.participant_id
    end
    Team.find_by(participant_id: winner_id).update_column(:disqualified, false)
    @match.update(winner_id: , loser_id: )
    url = "https://api.challonge.com/v1/tournaments/#{@match.tournament_id}/matches/#{@match.match_id}.json?api_key=#{ENV["API_KEY"]}&match[scores_csv]=#{@match.scores_csv}&match[winner_id]=#{winner_id}&match[loser_id]=#{loser_id}"
    response = HTTParty.put(url)
    if response.code == 200
      challonge_api = ChallongeApiService.new(cohors: @match.cohors)
      challonge_api.fetch_matches
    end
  end

  def challonge_host
    "https://api.challonge.com/v1/tournaments/#{ENV["TOURNAMENT"]}"
  end
end
