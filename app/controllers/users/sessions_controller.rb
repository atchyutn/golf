class Users::SessionsController < Devise::SessionsController
  before_action :check_team, only: :sign_in_with_magic_link

  def sign_in_with_magic_link
    user = User.find(params[:user])
    if user && !user.magic_link_token_expired?
      sign_in(user)
      redirect_to teams_path
    else
      flash[:alert] = 'Link is expire please request new login'
      redirect_to new_user_session_path
    end
  end

  def redirect_user
    invitation = begin
      Invitation.find_by(id: params[:invitation_id])
    rescue StandardError
      nil
    end
    if user_signed_in?
      check_team
      redirect_to teams_path
    else
      redirect_to new_user_session_path(invitation_id: invitation.id)
    end
  end

  def destroy
    current_user.go_offline! if current_user
    super
  end

  private

  def check_team
    return unless params[:invite_id].present? || params[:invitation_id].present?

    invite_id = params[:invite_id] || params[:invitation_id]
    invitation = Invitation.find(invite_id)
    parent_team = Team.find_by(id: invitation.team_id)
    user = User.find_by(email: invitation.invitee_email)
    team = Team.find_by(id: user.team_id)
    user.update(team_id: invitation.team_id,
                player_type: invitation.player_type)
    team.destroy
    # export_team_to_challonge(team: parent_team)
  end
end
