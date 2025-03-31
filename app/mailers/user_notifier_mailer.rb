class UserNotifierMailer < ApplicationMailer
	default :from => Rails.application.credentials.dig(:email, :brevo_email)

  def magic_link(user, provider = nil, invite_id: nil)
    @invite_id = invite_id
    @provider = provider
    @user = user
    mail to: user.email
  end

  def invite_user(invitation)
    @invitation = invitation
    mail to: invitation.invitee_email
  end

  def payment_successful
    @user = params[:user]
    mail to: @user.email
  end

  def tournament_started
    @user = params[:user]
    @tournament = params[:tournament]
    mail(to: @user.email, subject: "Tournament - #{@tournament.name} started")
  end

  def confirm_scores
    @user = params[:user]
    @url = match_summary_url(id: params[:match].id)
    mail(to: @user.email, subject: 'Confirm Your Scores')
  end

  def match_announcement
    @player = params[:player]
    @match = params[:match]
    mail(to: @player.email, subject: 'Match Announcement')
  end

  def message_notification(user, message, chat_room)
    @user = user
    @chat_room = chat_room
    @message = message
    mail(to: user.email, subject: "New Message in #{message.chat_room.name}")
  end
end
