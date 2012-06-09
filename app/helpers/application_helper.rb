module ApplicationHelper
  
  include ActiveAdmin::ViewHelpers
  
  def sprintapp_status_tag(label, color)
    content_tag(:span, label, class: "status #{color}")
  end
  
  def flash_notices
    raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }.join)
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    raw(content_tag(:div, content_tag(:div, content_tag(:span, submit_tag(label, :id => "commit"), :id => 'submit_or_cancel', :class => 'submit'), :class => "button") + ' or ' + link_to('Cancel', cancel_url), :class => "contactDiv leftButton") )
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end
  
  def main_site_url_for(options={})
    options.merge!({ :host => "www.#{request.domain}", :only_path => false })
    url_for options
  end
  
end
