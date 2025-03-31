class TeamsController < ApplicationController
	skip_before_action :authenticate_user!, only: :winner_teams
	def index
	end

	def remove_player
		player = User.find_by_email(params[:player_email])
	  team = Team.find(params[:team_id])
	  if team.players.include?(player)
			new_team = Team.create
			player.update!(team_id: new_team.id, player_type: 'captain')
			flash[:success] = "Player removed successfully"
	  else
	    flash[:error] = "Player not found in the team"
	  end
	  render partial: 'teams/teams'
	end

	def update_home_course
		team = Team.find(params[:team_id])
		team.update(home_course_id: params[:home_course_id])
		redirect_to teams_path
	end

	#change captain
	def update
		@match = Match.find(params[:match_id]) rescue nil
		@team = current_user.team
		user = User.find_by(id: params[:team][:captain])
		if current_user.team == @team
			current_user.update(player_type: user.player_type)
			user.update(player_type: 'captain')
			@team.captain = user
			render partial: 'matches/edit'
		else
			render json: { errors: 'you are not autorized to change captain' }
		end
	end

	def winner_teams
		teams = Team.with_completed_payment_and_two_players
		winners = params[:winners] == "true" ? teams.where(eliminated: false) : teams
		render json: winners, status: 200
	end
end
