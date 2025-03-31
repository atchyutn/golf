class PaymentsController < ApplicationController

	def create_checkout_session
    team = current_user.team
    # Check if the team has at least 2 players before proceeding
    if team.players.count < 2
      flash[:alert] = "Your team must have at least two players before making a payment."
      redirect_to root_path and return
    end
  
    # If valid, proceed with Stripe checkout session creation
    @session = Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'gbp',
            product_data: { name: 'Pay Sportingly LTD' },
            unit_amount: 24000, # Tournament entry fee
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: "#{Rails.configuration.action_mailer.default_url_options[:host]}/success",
      cancel_url: root_url,
      consent_collection: { terms_of_service: 'required' },
      custom_text: {
        terms_of_service_acceptance: {
          message: 'I agree to the [Terms of Service](https://example.com/terms)',
        },
      },
    )
  
    redirect_to @session.url, allow_other_host: true
  end
  

	def success
		current_user.team.update(payment_status: 'completed', paid_by: current_user.email)
    # export_team_to_challonge
    UserNotifierMailer.with(user: current_user).payment_successful.deliver_later
		redirect_to root_path
	end
end
