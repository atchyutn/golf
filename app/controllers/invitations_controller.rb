class InvitationsController < ApplicationController
	def create
		user = User.find_by(email: params[:invitation][:invitee_email])

		if user.present? && user.team.players.count > 1
			render json: { message: 'Player is already in a team'}, status: 500
		else
			invitation = Invitation.new(set_params)
			if invitation.save
				begin
					UserNotifierMailer.invite_user(invitation).deliver_later
				rescue Net::OpenTimeout => e
				  logger.error "Failed to send email to #{player.email}: #{e.message}"
				end
			end
			Rails.logger.info("invitation data #{invitation}")
			Rails.logger.info("invitation error #{invitation.errors.messages}")
			render partial: "teams/teams"
		end
	end

	private

	def set_params
		params.require(:invitation).permit(:invitee_email, :player_type, :user_id, :team_id)
	end
end
