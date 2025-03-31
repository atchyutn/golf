class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_validation, only: :create

  def create
    @user = User.find_or_initialize_by(sign_up_params)
    @user.add_to_team(sign_up_params[:invite_id],params[:user][:home_course_id])
    @user.password = Devise.friendly_token[0,20]
    @user.password_confirmation = @user.password
    yield @user if block_given?
    if @user.save
      if @user.active_for_authentication?
        set_flash_message! :notice, :signed_up
        redirect_to magic_links_path(user: @user, email: @user.email)
      else
        set_flash_message! :notice, :"signed_up_but_#{@user.inactive_message}"
        expire_data_after_sign_in!
        respond_with @user, location: after_inactive_sign_up_path_for(@user)
      end
    else
      clean_up_passwords @user
      set_minimum_password_length
      respond_with @user
    end
  end

  def update
    return unless current_user
    if current_user.update(sign_up_params)
      render json: {user: current_user}
    else
      render json: { errors: "#{current_user.errors.full_messages}" }, status: 500
    end
  end

  def add_profile_picture
    if current_user.image.attach(params[:image])
      render json: { success: true, message: "Profile picture uploaded successfully", image_url: url_for(current_user.image) }
    else
      render json: { success: false, message: "Failed to upload profile picture" }, status: :unprocessable_entity
    end
  end

  def sign_up_with_magic_link
    @user = User.find_by(email: params[:email])
    unless @user.magic_link_token_expired?
      @user.update(active: true)
      sign_up(:user, @user)
    else
      flash[:alert] = 'Link expired! please request another'
    end
    redirect_to teams_path
  end

  def get_email
    invitation = Invitation.find(params[:invite_id])
    if invitation
      render json: { email: invitation.invitee_email }
    end
  end

  def personal_information
    if (params[:email].present? || params[:user][:email].present?)
      @email = sign_up_params[:email] rescue params[:email]
      @invite_id = (sign_up_params[:invite_id] rescue nil) || (params[:invite_id] rescue nil)
      @user = User.new
      @provider = params[:provider] rescue nil
    else
      flash[:alert] = "email not found"
      redirect_to new_user_registration_path
    end
  end

  def update_personal_information
    user = User.find_by(email: sign_up_params[:email]) rescue nil
    user.team.update(home_course_id: params[:user][:home_course_id]) if user.captain?
    if user
      if user.update(sign_up_params.merge({active: true}))
         sign_up(:user, user)
         redirect_to teams_path
       else
        flash[:alert] = user.errors.full_messages[0]
        redirect_to personal_information_path(email: params[:user][:email], provider: params[:user][:provider])
       end
    end
  end

  def check_validation
    if params[:user][:first_name].empty?
      flash[:alert] = "First Name can't be blank"
      redirect_to personal_information_path(sign_up_params)
    end
  end

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :country, :postcode, :handicap, :phone_number, :email, :magic_link_token, :active, :player_type, :invite_id, :home_course_id, :provider)
  end
end