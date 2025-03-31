class ChallongeApiService
  include HTTParty
  base_uri 'https://api.challonge.com/v2.1'

  def initialize(cohors: )
    @cohors = cohors
    @headers = {
      "Content-Type" => "application/vnd.api+json",
      "Accept" => "application/json",
      "Authorization" => ENV['API_KEY'],
    }
  end

  def create_tournament(name:, tournament_type:, starts_at:, description: )
    body = {
      data: {
        type: "Tournaments",
        attributes: {
          name: name,
          tournament_type: tournament_type,
          game_name: 'golf',
          starts_at: starts_at,
          description: description
        }
      }
    }

    # Add double elimination options only if the tournament type is "double elimination"
    if tournament_type == "double elimination"
      body[:data][:attributes][:double_elimination_options] = {
        split_participants: false,
        grand_finals_modifier: "single match"
      }
    end

    options = {
      headers: @headers,
      body: body.to_json
    }

    response = self.class.post('/tournaments.json', options)
    attributes = response["data"]["attributes"]
    @cohors.update(
      tournament_id: response["data"]["id"],
      game_name: attributes["game_name"],
      full_challonge_url: attributes["full_challonge_url"],
      live_image_url: attributes["live_image_url"],
      url: attributes["url"]
    )
    add_participants
  end

  def start_tournament
    endpoint = "/tournaments/#{@cohors.url}/change_state.json"
     body = {
       data: {
         type: "TournamentState",
         attributes: {
           state: "start"
         }
       }
     }.to_json
    response = self.class.put(endpoint, headers: @headers, body: body)
    
    return { errors: response["errors"][0]["detail"] } if response.code != 200
    @cohors.update(state: response["data"]["attributes"]["state"])
    fetch_matches
    return 200
  end

  def fetch_matches
    endpoint = "/tournaments/#{@cohors.url}/matches.json"
    response = self.class.get(endpoint, headers: @headers)

    if response.code == 200
      matches = response["data"]
      matches.each do |match|
        player1_id = match["attributes"]["points_by_participant"][0]["participant_id"]
        player2_id = match["attributes"]["points_by_participant"][1]["participant_id"]
        cohors_match = @cohors.matches.find_or_create_by(match_id: match["id"])

        cohors_match.update(round: match["attributes"]["round"],
                            tournament_id: @cohors.tournament_id,
                            player1_id:,
                            player2_id:,
                            status: match_status(match, cohors_match)
                            )

        # add teams to match
        teams = Team.where.not(participant_id: nil).where(participant_id: [player1_id, player2_id].compact)
        existing_team_ids = cohors_match.teams.pluck(:id).to_set
        MatchTeam.where(match_id: cohors_match.id, team_id: (existing_team_ids.to_a - teams.ids)).destroy_all
        new_teams = teams.reject { |team| existing_team_ids.include?(team.id) }
        cohors_match.teams << new_teams

        # assign home team
        unless cohors_match.teams.pluck(:home).any?(true)
          cohors_match.teams.first.update(home: true) rescue nil
        end
        home_teams = cohors_match.teams.where(home: true)
        if home_teams.count > 1
          home_teams.last.update(home: false) rescue nil
        end
      end
    else
      puts "Error fetching matches: #{response.code} - #{response.parsed_response['errors'].first}"
    end
  end

  def add_participants
    remove_participants
    @cohors.teams.each do |team|
      endpoint = "/tournaments/#{@cohors.url}/participants.json"
      team_name = team.name || "team_#{SecureRandom.random_number(10**2)}"
      body = {
        data: {
          type: 'Participants',
          attributes: {
            name: team_name
          }
        }
      }

      options = {
            headers: @headers,
            body: body.to_json
          }
      response = if team.participant_id.nil? || (team.eliminated == false)
                  self.class.post(endpoint, options)
                end
      team.update(participant_id: response["data"]["id"], tournament_id: @cohors.tournament_id) if response&.code == 201
    end
  end

  def remove_participants
    saved_team_ids = Team.where(tournament_id: @cohors.tournament_id).pluck(:participant_id)
    existing_teams_ids = @cohors.teams.pluck(:participant_id)
    removable_ids = saved_team_ids - existing_teams_ids
    if removable_ids.present?
      removable_ids.each do |participant_id|
        endpoint = "/tournaments/#{@cohors.tournament_id}/participants/#{participant_id}.json"
        response = self.class.delete(endpoint, headers: @headers)
        team = Team.find_by(participant_id: participant_id)
        team.update(participant_id: nil, tournament_id: nil)
      end
    end
  end

  def update_tournament
    url = "/tournaments/#{@cohors.url}.json"
    body = {
      data: {
        type: "Tournaments",
        attributes: {
          name: @cohors.name,
          tournament_type: @cohors.tournament_type,
          starts_at: @cohors.starts_at,
          description: @cohors.description
        }
      }
    }

    options = {
      headers: @headers,
      body: body.to_json
    }
    response = self.class.put(url, options)
    unless response.success?
      raise "Failed to update tournament on Challonge: #{response['errors']}"
    end
  end

  def delete_tournament
    end_point = "/tournaments/#{@cohors.url}.json"
    response = self.class.delete(end_point, headers: @headers)
    @cohors.teams.update_all(participant_id: nil) if response.code == 204
  end

  def complete_tournament
    endpoint = "/tournaments/#{@cohors.url}/change_state.json"
    body = {
      data: {
        type: "TournamentState",
        attributes: {
          state: "finalize"
        }
      }
    }
    options = {
      headers: @headers,
      body: body.to_json
    }
    response = self.class.put(endpoint, options)
    @cohors.complete! if response.code == 200
  end

  def match_status(match, cohors_match)
    if cohors_match.started?
      "started"
    else
      case match["attributes"]["state"]
      when "open"
        return "upcoming"
      when "pending"
        return "upcoming"
      else
        return "completed"
      end
    end
  end
end
