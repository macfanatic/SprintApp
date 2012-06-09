ActiveAdmin.register_page "Calendar" do
  
  menu :priority => 2
  
  action_item do
    link_to "New Ticket", new_ticket_path if can?(:create, Ticket)
  end
    
  content do
    
    if resource_class == Ticket
      controller.filter :project, :as => :select, :collection => proc { Project.active.accessible_by(current_ability) }
      controller.filter :ticket_priority, :collection => proc { TicketPriority.all }
      controller.filter :billable
      controller.filter :ticket_category, :collection => proc { TicketCategory.all }
      controller.filter :milestone, :collection => proc { Milestone.where(project_id: Project.accessible_by(current_ability).pluck(:id)) }
      controller.filter :assignee, :collection => proc { AdminUser.sorted } unless current_admin_user.employee?
      controller.filter :name
    else
      controller.filter :project, :as => :select, :collection => proc { Project.active.accessible_by(current_ability) }
      controller.filter :name
    end
        
    image_tag "ajax_loader.gif", :id => "loading"
    div :id => 'calendar_holder'
  end
  
  sidebar :filters    
  sidebar :calendar_help
  
  controller do
    
    before_filter :clear_saved_search_params, :only => :index
    
    def clear_saved_search_params
      session[:calendar] = current_admin_user.employee? ? { saved_search_params: { assignee_id_eq: current_admin_user.id } } : {}
    end
    
    def resource_class
      @resource_class ||= Ticket
    end
    
    def saved_search_params
      @saved_search_params ||= session[:calendar][:saved_search_params]
    end
    
    def events
     
      @start_date = Time.at(params[:start].to_i).to_date
      @end_date = Time.at(params[:end].to_i).to_date
      @tickets = searched_collection(Ticket.where('tickets.start_date BETWEEN ? AND ? OR tickets.end_date BETWEEN ? AND ?', @start_date, @end_date, @start_date, @end_date).where(project_id: Project.accessible_by(current_ability).pluck(:id)))

      respond_to do |format|
        format.json { render :json => @tickets.as_json(:user => current_admin_user) }
      end
    end
    
    def set_filters
      session[:calendar] ||= {}
      session[:calendar][:saved_search_params] = clean_search_params(params[:q])
      session[:calendar][:saved_search_params][:assignee_id_eq] = current_admin_user.id if current_admin_user.employee?
      render :json => true, :layout => false
    end
    
    # Searching  
    def filter(attribute, options = {})
      return false if attribute.nil?
      @filters ||= []
      @filters << options.merge(:attribute => attribute)
    end

    def filters_config
      @filters && @filters.any? ? @filters : []
    end

    def search(chain)
      @search = chain.metasearch(clean_search_params(saved_search_params))
      @search.relation
    end

    def clean_search_params(search_params)
      return {} unless search_params.is_a?(Hash)
      search_params = search_params.dup
      search_params.delete_if do |key, value|
        value == ""
      end
      search_params
    end

    def search_params
      resource_class.search
    end

    # Searching the collection
    def searched_collection(chain)
      search(chain)
    end
    
  end
  
end