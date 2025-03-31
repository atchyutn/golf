class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  include ChallongeApi

  before_action do
    ActiveStorage::Current.url_options = Rails.application.config.action_mailer.default_url_options
  end
  rescue_from Net::OpenTimeout, with: :handle_open_timeout

  private

  def handle_open_timeout(exception)
    # Handle the exception
    Rails.logger.error "Net::OpenTimeout occurred: #{exception.message}"
    flash[:error] = "A network timeout occurred. Please try again later."
    redirect_back(fallback_location: root_path)
  end
end
