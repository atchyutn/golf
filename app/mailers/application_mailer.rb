class ApplicationMailer < ActionMailer::Base
  default from: 'my-email@gmail.com'
  layout 'mailer'
end
