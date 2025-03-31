class TournamentService
  def initialize(cohors)
    @cohors = cohors
    @logger = Rails.logger
  end

  def start_tournament
    return { errors: "Tournament is already underway" } if @cohors.underway?
    return { errors: "Not enough teams to start tournament" } if @cohors.teams.count < 2

    @cohors.update!(state: "underway")
    generate_matches
    notify_participants
    { errors: "Tournament is started" , status: 200}
  rescue StandardError => e
    @logger.error "Failed to start tournament: #{e.message}"
    { errors: "Tournament start failed: #{e.message}" }
  end

  def generate_matches
    case @cohors.tournament_type

    when "single_elimination"
      generate_single_elimination_matches
    when "double_elimination"
      generate_double_elimination_matches
    else
      raise "Unsupported tournament type"
    end
  end


  def update_match_standings
    @cohors.matches.each do |match|
      total_score = calculate_scores_for_match(match)
      match.update(final_standing: total_score)
      Rails.logger.info "Updated standings for match ##{match.id}: #{total_score}"
    end
  end

  private

  # def generate_single_elimination_matches
  #   teams = @cohors.teams.to_a.shuffle
  #   @logger.info "Shuffled teams: #{teams.map(&:name)}"
    
  #   # Handle bye rounds
  #   if teams.size.odd?
  #     bye_team = teams.pop
  #     @logger.info "Bye team: #{bye_team.name} automatically advances"
  #     advance_team(bye_team)
  #   end

  #   round = 1
  #   while teams.size > 1
  #     next_round_teams = []
  #     teams.each_slice(2) do |team1, team2|
  #       match = create_match(team1, team2, round)
  #       next_round_teams << match if match
  #     end
  #     teams = next_round_teams.map(&:winner)
  #     round += 1
  #   end
  # end

  def generate_single_elimination_matches
    teams = @cohors.teams.to_a.shuffle
    Rails.logger.info "Shuffled teams: #{teams.map(&:name)}"

    rounds = Math.log2(teams.size).ceil
    next_round_teams = nil # Store the advancing team

    (1..rounds).each do |round|
      if round == 1
        while teams.size >= 1
          team1 = teams.shift
          team2 = teams.shift

          if team2.nil?
            # Odd number of teams → Give a bye, move team to next round
            Rails.logger.info "Bye: #{team1.name} automatically advances"
            next_round_teams = team1
            match = @cohors.matches.create!(
              player1_id: team1&.id,
              player2_id: nil,
              round: round,
              status: "completed",
              cohors_id: @cohors.id,
              winner_id: team1.id
            )
            MatchTeam.create(match: match, team: team1) if match
          else
            match = create_match(team1, team2, round)
            next_round_teams = nil # Reset after match
          end
        end
      else
        match_count = @cohors.matches.where(round: round - 1).count.to_f / 2
        match_count = match_count == 1.5 ? 2 : match_count.to_i
        match_count = match_count.zero? ? 1 : match_count
        match_count.times do |val|
          match = @cohors.matches.create!(
            player1_id: next_round_teams&.id,
            player2_id: nil,
            round: round,
            status: "upcoming",
            cohors_id: @cohors.id
          )
          if match.player1_id
            MatchTeam.create(match: match, team: next_round_teams)
            next_round_teams = nil 
          end
        end
      end
    end
  end

  def generate_double_elimination_matches
    teams = @cohors.teams.to_a.shuffle
    winner_bracket = teams.dup
    loser_bracket = []
    round = 1
  
    while winner_bracket.size > 1 || loser_bracket.size > 1
      next_winner_round = []
      next_loser_round = []
  
      winner_bracket.each_slice(2) do |team1, team2|
        Rails.logger.info("Creating match between #{team1&.id} and #{team2&.id} for round #{round}")
        match = create_match(team1, team2, round)
        
        if match.persisted?
          next_winner_round << match
          loser_bracket << match.loser if match.loser
        else
          Rails.logger.error("Failed to create match: #{match.errors.full_messages}")
        end
      end
  
      loser_bracket.each_slice(2) do |team1, team2|
        Rails.logger.info("Creating loser bracket match between #{team1&.id} and #{team2&.id} for round #{round}")
        match = create_match(team1, team2, -round)
  
        if match.persisted?
          next_loser_round << match
        else
          Rails.logger.error("Failed to create loser match: #{match.errors.full_messages}")
        end
      end
  
      winner_bracket = next_winner_round.map(&:winner)
      loser_bracket = next_loser_round.map(&:winner)
      round += 1
    end
  end
  
  def create_match(team1, team2, round)
    return nil unless team1 && team2

    match = @cohors.matches.create(
      player1_id: team1.id,
      player2_id: team2.id,
      round: round,
      status: "upcoming",
      cohors_id: @cohors.id # Ensure this is set
    )

    # Create match teams associations
    if match.persisted?
      MatchTeam.create(match: match, team: team1)
      MatchTeam.create(match: match, team: team2)
      
      Rails.logger.info("Successfully created match ##{match.id} (#{team1.name} vs #{team2.name})")
    else
      Rails.logger.error("Match creation failed: #{match.errors.full_messages}")
    end

    match
  end

  def advance_team(team)
    @logger.info "Team #{team.name} advances automatically"
    team
  end

  def notify_participants
    @cohors.teams.includes(:players).each do |team|
      team.players.each do |player|
        UserNotifierMailer.with(user: player, tournament: @cohors).tournament_started.deliver_later
      end
    end
  end

  def finalize_tournament
    @cohors.update(state: "complete")
  end

  def calculate_scores_for_match(match)
    # Implement your logic to calculate scores based on the match's hole scores
    hole_scores = match.hole_scores
    return 0 unless hole_scores.any?

    team1_wins = hole_scores.where(winner: "team1").count
    team2_wins = hole_scores.where(winner: "team2").count
    final_standing = team1_wins - team2_wins

    match.teams.first.update(final_standing: team1_wins)
    match.teams.second.update(final_standing: team2_wins)

    Rails.logger.info "Match ##{match.id}: Team 1 Wins = #{team1_wins}, Team 2 Wins = #{team2_wins}, Final Standing = #{final_standing}"
    
    final_standing
  end
end
