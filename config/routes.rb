Timetracker::Application.routes.draw do
  
  post '/calendar/filter', :to => 'calendar#set_filters', :as => 'filter_calendar'    
  get '/calendar/events', :to => 'calendar#events', :as => 'calendar_events'

  devise_for :admin_users, ActiveAdmin::Devise.config        
  ActiveAdmin.routes(self)
  
  devise_scope :admin_user do
    get '/logout', :to => 'active_admin/devise/sessions#destroy', :as => "destroy_admin_user_session"
    get '/login', :to => 'active_admin/devise/sessions#new', :as => "new_admin_user_session"
    post '/login', :to => 'active_admin/devise/sessions#create', :as => "create_admin_user_session"
  end
   
end
