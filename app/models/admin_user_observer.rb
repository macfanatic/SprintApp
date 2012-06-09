class AdminUserObserver < ActiveRecord::Observer
    
  def after_create(user)
    AdminUserMailer.welcome_email(user).deliver if user.send_welcome_email?
  end
  
end
