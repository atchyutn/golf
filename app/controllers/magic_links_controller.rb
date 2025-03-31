class MagicLinksController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @email = params[:email]
  end

  def create
    invite_id = set_params[:invite_id] rescue nil
    user = User.find_by_email(set_params[:email])
    if user
      user.generate_magic_link_token
      user.save
      begin
        UserNotifierMailer.magic_link(user, invite_id: invite_id).deliver_later
      rescue Net::OpenTimeout => e
        logger.error "Failed to send email to #{player.email}: #{e.message}"
      end
      flash[:notice] = 'Magic link sent!'
      redirect_to magic_links_path(email: set_params[:email])
    else
      flash[:alert] = 'Please signup'
      redirect_to root_path
    end
  end

  def faqs
  end

  def about_the_challenge
  end

  private

  def set_params
    params.require(:user).permit(:email, :invite_id)
  end
end
