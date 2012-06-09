class ApplicationController < ActionController::Base
  
  helper :all
  
  protect_from_forgery
  
  def current_user
    current_admin_user
  end
  
  def user_signed_in?
    admin_user_signed_in?
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
  
  before_filter :set_timezone
  before_filter :correct_safari_and_ie_accept_headers
  after_filter :set_xhr_flash
  
  rescue_from CanCan::AccessDenied do |exception|
    begin
      redirect_to :back, :alert => exception.message
    rescue ActionController::RedirectBackError
      redirect_to dashboard_path, :alert => exception.message
    end
  end
  
  protected
  
    # got these tips from
    # http://lyconic.com/blog/2010/08/03/dry-up-your-ajax-code-with-the-jquery-rest-plugin
    def set_xhr_flash
     flash.discard if request.xhr?
    end

    def correct_safari_and_ie_accept_headers
     ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
     request.accepts.sort! { |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
    end
  
    def set_timezone
      Time.zone = current_admin_user.time_zone if current_admin_user and !current_admin_user.time_zone.blank?
    end
  
end
