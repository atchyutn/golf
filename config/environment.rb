# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!
ActionMailer::Base.smtp_settings = {
    address: "smtp-relay.brevo.com",
    port: 587,
    authentication: "login",
    user_name: Rails.application.credentials.dig(:email, :brevo_email), 
    password: Rails.application.credentials.dig(:email, :brevo_password),
    enable_starttls_auto: true
}
