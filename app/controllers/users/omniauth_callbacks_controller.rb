class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    if request.env["omniauth.params"]["action_type"] == 'signin'
      handle_sign_in
    else
      handle_sign_up
    end
  end

  private

  def handle_sign_in
    @user = User.find_by(email: auth.info.email)
    if @user.present?
      sign_out_all_scopes
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: 'Google')
      sign_in(@user)
      redirect_to root_url
    else
      flash[:alert] = "User not found, Please SignUp"
      redirect_to new_user_session_path
    end
  end

  def handle_sign_up
    @user = User.from_omniauth(from_google_params)
    sign_out_all_scopes
    flash[:notice] = t('devise.omniauth_callbacks.success', kind: 'Google')
    redirect_to personal_information_url(email: @user.email, provider: @user.provider, invite_id: from_google_params[:invite_id])
  end

  def from_google_params
    @from_google_params ||= {
      uid: auth.uid,
      email: auth.info.email,
      invite_id: request.env["omniauth.params"]["invite_id"]
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
