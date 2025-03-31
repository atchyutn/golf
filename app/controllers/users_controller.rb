class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def set_online
    return unless check_user?

    current_user.go_online!
    head :ok
  end

  def set_offline
    return unless check_user?

    current_user.go_offline!
    head :ok
  end

  private

  def check_user?
    current_user.present?
  end
end
