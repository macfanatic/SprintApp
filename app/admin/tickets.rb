ActiveAdmin.register Ticket, :sort_order => "ticket_priority_id_desc" do
  
  # for use with cancan
  controller.authorize_resource
  controller.resources_configuration[:self][:finder] = :find_by_url!
  
  belongs_to :project, finder: :find_by_url!, optional: true
  before_filter :find_ticket, only: [:move, :start_timer, :stop_timer, :ticket_time]
  
  menu :parent => "Projects", :label => "All Tickets"
    
  form :partial => "form"
  
  scope(:all)
  scope(:open, default: true) { |tickets| tickets.active }
  scope(:mine) { |tickets| tickets.active.owned_by(current_admin_user) }
  scope :closed
  scope :overdue

  filter :number, label: "Ticket ID#"
  filter :project, :as => :select, :collection => proc { @project.nil? ? Project.accessible_by(current_ability).active : [@project] }
  filter :ticket_priority, :collection => proc { TicketPriority.all }
  filter :milestone, :collection => proc { @project.milestones.active.sorted rescue Milestone.where(project_id: Project.accessible_by(current_ability).pluck(:id)).active }
  filter :billable, :as => :select
  filter :ticket_category, :collection => proc { TicketCategory.all }
  filter :status, :collection => proc { TicketStatus.all }
  filter :assignee, :collection => proc { @project.members.active.sorted rescue AdminUser.active }
  filter :start_date
  filter :end_date
  filter :estimated_time
  filter :actual_time
  filter :name
  filter :description
  filter :created_at
  filter :updated_at
  
  action_item only: [:show, :edit] do
    if can? :advanced_edit, resource
      link_to "Move", move_ticket_path(resource)
    end
  end
  
  # This adds a "New Ticket" button to the show view, and leaves the other "New Ticket" buttons alone everywhere else
  action_item :only => :show do
    if controller.current_ability.can?(:create, active_admin_config.resource_name.underscore.camelize.constantize)
      if controller.action_methods.include?('new')
        link_to(I18n.t('active_admin.new_model', :model => active_admin_config.resource_name), new_resource_path)
      end
    end
  end
  
  batch_action :edit do |selected_ids|
    @ticket_ids = selected_ids
    @project = Project.find_by_url! params[:project_id]
    @statuses = TicketStatus.all
    @categories = TicketCategory.all
    @priorities = TicketPriority.all
    @prompt = "&raquo; No Change &laquo;"
    render 'multiple_edit_form'
  end
  
  batch_action :destroy, { if: proc{ can? :destroy, Ticket }, priority: 100, confirm: I18n.t('active_admin.batch_actions.delete_confirmation', plural_model: "tickets") } do |selected_ids|
    Ticket.destroy_all id: selected_ids
    redirect_to collection_path, :notice => I18n.t("active_admin.batch_actions.succesfully_destroyed", count: selected_ids.count, model: "ticket", plural_model: "tickets")
  end
  
  csv do
    column(:id) { |t| t.number }
    column(:name) { |t| t.name }
    column(:description) { |t| truncate strip_tags(t.description), length: 300 }
    column(:priority) { |t| ticket_priority t }
    column(:status) { |t| ticket_status t }
    column(:assignee) { |t| ticket_assignee t }
    column(:tracker) { |t| t.ticket_category.display_name }
    column(:estimated_time)
    column(:actual_time)
    column(:start) { |t| t.start_date }
    column(:end) { |t| t.end_date }
    column(:created_at)
    column(:updated_at)
  end
  
  index do |t|
    selectable_column
    column("ID", sortable: :number) { |ticket| link_to ticket.number, [ticket.project, ticket], title: ticket.name }
    column("Name", :sortable => :name) { |ticket| link_to( truncate(ticket.name, :length => 25), project_ticket_path(ticket.project, ticket), title: ticket.name ) }
    column("Priority", :sortable => :ticket_priority_id) { |ticket| priority_tag_for_ticket(ticket) }
    column("Billable", sortable: :billable) { |ticket| ticket_billable_status_tag(ticket) }
    column :assignee, :sortable => :assignee_id
    column("Status", :sortable => :status_id) { |ticket| status_tag_for_ticket_status(ticket) }
    column("Tracker", :sortable => :ticket_category_id) { |ticket| ticket.ticket_category.display_name }
    column("Health", :sortable => :budget_progress) { |ticket| simple_budget_progress_indicator(ticket.actual_time, ticket.estimated_time) }
    column("Start", :sortable => :start_date) { |ticket| status_tag( ticket.start_date.humanize, colorize_ticket_by_start_date(ticket) ) }
    column("Due", :sortable => :end_date) { |ticket| status_tag_for_ticket_by_due_date(ticket) }
    restricted_actions_column(t)
  end
  
  show :title => :display_name do
    panel 'Ticket Details: %s' % title do
      div :class => "attributes_table" do
        table :for => resource do |t|
          tr(:id => 'ticket_name') do
            th(:colspan => 4) { resource.name }
          end
          tr do
            th { 'Tracker' }
            td { resource.ticket_category.display_name }
            th { 'Milestone' }
            td do
              if resource.milestone.present?
                link_to( resource.milestone.display_name, roadmap_project_milestone_path(resource.project, resource.milestone) ) 
              else
                span(class: :empty) { "empty" }
              end
            end
          end
          tr do
            th { 'Status' }
            td { status_tag_for_ticket_status(resource) }
            th { 'Assignee' }
            td do
              if resource.assignee
               link_to resource.assignee.full_name, admin_user_path(resource.assignee)
              end
            end
          end
          tr do
            th { 'Priority' }
            td { priority_tag_for_ticket(resource) }
            th { 'Author' }
            td { created_by resource }
          end
          tr do
            th { 'Start' }
            td { status_tag( ticket.start_date.humanize, colorize_ticket_by_start_date(resource) ) }
            th { 'Due' }
            td { status_tag_for_ticket_by_due_date(resource) }
          end
          tr do
            th { 'Description' }
            td(:colspan => 3) { resource.description.html_safe }
          end
        end
      end
    end
    
    unless resource.ticket_comments.empty?
      text_node(render partial: "history", locals: { ticket: resource })
    end
    
    form action: edit_project_ticket_path(resource.project, resource), method: :get, id: :edit_ticket_button do
      div class: :buttons do
        input type: :submit, class: :update, value: "Edit Ticket"
      end
    end
    
  end
  
  sidebar "Budget & Timing", :only => :show do
    @ticket_timer = TicketTimer.where(admin_user_id: current_admin_user.id, ticket_id: resource.id)
    render partial: "budget_and_timing_sidebar", locals: { wrapper_class: @ticket_timer.present? ? :stop : :start }
  end
  
  sidebar :watchers, :only => :show
  
  member_action :move
  
  member_action :start_timer, method: :post do
    
    @timer_count = TicketTimer.where(admin_user_id: current_admin_user.id).count
    
    # If existing timer, stop this one
    scope = TicketTimer.where(admin_user_id: current_admin_user.id)
    if scope.exists?
      old_timer = scope.first
      stop_and_update_timer(old_timer.ticket, old_timer)
    end
    
    # Start a new timer
    @ticket_timer = TicketTimer.create admin_user: current_admin_user, ticket: @ticket
    respond_to do |format|
      format.html { redirect_to project_ticket_path(@ticket.project, @ticket) }
      format.js
    end
    
  end
  
  member_action :ticket_time do
    @ticket_timer = TicketTimer.find(:first, conditions: { admin_user_id: current_admin_user.id, ticket_id: @ticket.id })
    respond_to do |format|
      format.html { redirect_to project_ticket_path(@ticket.project, @ticket) }
      format.js
    end
  end
  
  member_action :stop_timer, method: :post do
    
    @ticket_timer = TicketTimer.find(:first, conditions: { admin_user_id: current_admin_user.id, ticket_id: @ticket.id })
    return if @ticket_timer.nil?
    
    @comment = stop_and_update_timer(@ticket, @ticket_timer)
    
    respond_to do |format|
      format.html { redirect_to project_ticket_path(@ticket.project, @ticket) }
      format.js
    end
  
  end
  
  collection_action :update_comment, method: :post do
    
    @ticket_comment = TicketComment.find(params[:id], include: :ticket)
    ticket_comment_previous_time = @ticket_comment.time
    @ticket_comment.time = params[:time]
    if @ticket_comment.save
      
      # Don't want to generate a new Version object
      # Have to manually modify an older Version object anyway
      @ticket_comment.ticket.update_column :actual_time, @ticket_comment.ticket.ticket_comments.sum(:time)
      ticket_version = Version.find(@ticket_comment.version_id)
      changeset = ticket_version.changeset
      before = changeset[:actual_time].first
      after = changeset[:actual_time].last
      after = after - ticket_comment_previous_time + @ticket_comment.time
      changeset[:actual_time] = [before, after]
      ticket_version.update_column :object_changes, changeset.to_yaml
      
    end
    
    respond_to do |format|
      format.js
      format.html do 
        if @ticket_comment.valid?
          format.html { redirect_to project_ticket_path(@ticket_comment.ticket.project, @ticket_comment.ticket), notice: "Time was successfully updated." }
        else
          format.html { redirect_to project_ticket_path(@ticket_comment.ticket.project, @ticket_comment.ticket), alert: "Unable to update time." }
        end
      end
    end
    
  end
  
  collection_action :edit_multiple, method: :post do
    
    collection = Ticket.find(params[:collection])
    redirect_to collection_path, alert: "No tickets were modified" and return if params[:status].blank? && params[:tracker].blank? && params[:priority].blank? && params[:assignee].blank? && params[:billable].blank?
    
    saved = 0
    collection.each do |ticket|
            
      ticket.status_id = params[:status] if params[:status].present?
      ticket.ticket_category_id = params[:tracker] if params[:tracker].present?
      ticket.ticket_priority_id = params[:priority] if params[:priority].present?
      ticket.assignee_id = params[:assignee] if params[:assignee].present?
      ticket.billable = params[:billable] if params[:billable].present?
      
      ticket.ticket_comments << TicketComment.new(ticket: ticket)
      saved += 1 if ticket.save
      
    end
    
    redirect_to collection_path, notice: "Updated #{saved} of #{params[:collection].length} tickets"
    
  end
  
  controller do
    def find_ticket
      @ticket = Ticket.find_by_url! params[:id]
    end
    def scoped_collection
      chain = end_of_association_chain.accessible_by(current_ability)
      chain = chain.where(projects: { completed: false }) if @project.nil?
      chain
    end
    def new
      redirect_to(tickets_path, alert: "You are not allowed to access this page.") and return if params[:project_id].blank?
      new! do
        @ticket = Ticket.new
      end
    end
    def edit
      redirect_to edit_project_ticket_path(resource.project, resource) and return if params[:project_id].blank?
      super
    end
    def stop_and_update_timer(ticket, timer)
      time = timer.elapsed_time / 3600
      comment = TicketComment.new(time: time, ticket: ticket)
      if time >= 0.01
        ticket.ticket_comments << comment
        ticket.save(validate: false)
        comment.send(:set_version)
        comment.save
      end
      timer.destroy
      comment
    end
  end
  
end
