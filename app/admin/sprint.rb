ActiveAdmin.register_page "Sprint" do
    
  menu :label => "Current Sprint", :priority => 3
  
  controller do
    
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
      @search = chain.metasearch(clean_search_params(params[:q]))
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
      Ticket.search(clean_search_params(params[:q]))
    end
    
    # Sorting
    def sort_order(chain)
      params[:order] ||= "end_date_asc"
      if params[:order] && params[:order] =~ /^([\w\_\.]+)_(desc|asc)$/
        column = $1
        order  = $2
        table  = "tickets"
        table_column = (column =~ /\./) ? column : "#{table}.#{column}"

        chain.order("#{table_column} #{order}")
      else
        chain # just return the chain
      end
    end
    
    # Searching/Sorting the collection
    def sorted_searched_collection(chain)
      scoped_collection(search(sort_order(chain)))
    end
    
    include ActiveAdmin::ScopeChain
    
    def scoped_collection(chain)
      
      scope = get_scope_by_id(params[:scope]) || default_scope
      unless scope.nil?
        scope_chain(scope, chain)
      else
        chain
      end
      
    end
    
    def scopes
      @scopes ||= []
    end
    
    # Returns a scope for this object by its identifier
    def get_scope_by_id(id)
      id = id.to_s
      scopes.find{|s| s.id == id }
    end

    def default_scope
      @default_scope
    end
    
    def add_scope(*args, &block)
      options = args.extract_options!
      title = args[0] rescue nil
      method = args[1] rescue nil

      scope = ActiveAdmin::Scope.new(title, method, options, &block)

      # Finds and replaces a scope by the same name if it already exists
      existing_scope_index = scopes.index{|existing_scope| existing_scope.id == scope.id }
      if existing_scope_index
        scopes.delete_at(existing_scope_index)
        scopes.insert(existing_scope_index, scope)
      else
        self.scopes << scope
      end

      @default_scope = scope if options[:default]

      scope
    end
    
    def current_scope?(scope)
      if params[:scope]
        params[:scope] == scope.id
      else
        default_scope == scope
      end
    end
    helper_method :current_scope?
    
    def get_scope_count(scope)
      scope_chain(scope, Ticket).count
    end
    helper_method :get_scope_count
    
    def index
      project_ids = Project.accessible_by(current_ability)
      unfiltered_tickets = Ticket.where(project_id: project_ids).current_sprint
      unfiltered_tickets = unfiltered_tickets.owned_by(current_admin_user) if current_admin_user.employee?
      @tickets = sorted_searched_collection(unfiltered_tickets)
      @milestones = Milestone.where(project_id: project_ids).current_sprint

      render layout: "active_admin"
    end
    
  end
  
  controller.before_filter do
    add_scope :all, default: true
    Team.find_each do |team|
      add_scope(team.name) { |tickets| tickets.where assignee_id: team.admin_users }
    end
  end
  
  sidebar :filters    
  sidebar :sprint_statistics do
    
    project_ids = Project.accessible_by(current_ability)
    @tickets = Ticket.where(project_id: project_ids).current_sprint
    @milestones = Milestone.where(project_id: project_ids).current_sprint
    @num_assignees = @tickets.select(:assignee_id).uniq { |t| t.assignee_id }.count
    @total_hours = @tickets.sum(:estimated_time)
    
    render :partial => 'sprint_statistics_sidebar', :locals => { tickets: @tickets, milestones: @milestones, num_assignees: @num_assignees, total_hours: @total_hours }
    
  end
  sidebar :sprint_help
    
end