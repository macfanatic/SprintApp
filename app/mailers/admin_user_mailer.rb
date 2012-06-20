class AdminUserMailer < ActionMailer::Base
  default from: Settings.email.notifications_sender
  layout "mailer"
  
  def welcome_email(user)
    @user = user
    mail to: user.email, subject: subject
  end
  
  private
    
    def subject
      "Welcome to SprintApp!"
    end
  
end
