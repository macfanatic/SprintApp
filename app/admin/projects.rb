ActiveAdmin.register Project, :sort_order => "number_asc" do
    
  menu :priority => 4
  
  # for use with cancan
  controller.authorize_resource find_by: :url
  controller.resources_configuration[:self][:finder] = :find_by_url!
    
  before_filter :set_project, only: [:whiteboard, :edit_whiteboard, :save_whiteboard, :switch, :archive, :unarchive, :roadmap]
    
  filter :number
  filter :client, :collection => proc { Client.all }
  filter :product_owner, :collection => proc { AdminUser.admin }
  filter :name
  filter :start_date
  filter :end_date
  filter :desciprtion
  filter :created_at
  filter :updated_at
  
  scope :all
  scope :active, default: true
  scope :closed
  
  action_item :only => [:show] do
    if controller.current_ability.can?(:archive, Project)
      if resource.completed?
        link_to "Activate", unarchive_project_path(resource), confirm: "Are you sure you want to make this project active?"
      else
        link_to "Deactivate", archive_project_path(resource), confirm: "Are you sure you want to archive this project?\nYou can still view all project data, or unarchive the project later."
      end
    end
  end
  
  controller do
    def scoped_collection
      end_of_association_chain.accessible_by(current_ability)
    end
  end
  
  batch_action :archive, { if: proc { can? :archive, Project }, confirm: 'Are you sure you want to archived these projects?' } do |selected_ids|
    Project.find(selected_ids).each { |u| u.archive! }
    redirect_to collection_path, notice: "Succesfully archived #{selected_ids.count} projects."
  end
  
  batch_action :unarchive, { if: proc{ can? :unarchive, Project }, confirm: 'Are you sure you want to unarchive these projects?' } do |selected_ids|
    Project.find(selected_ids).each { |u| u.unarchive! }
    redirect_to collection_path, notice: "Successfully unarchived #{selected_ids.count} projects."
  end
  
  batch_action :destroy, { if: proc{ can? :destroy, Project }, priority: 100, confirm: I18n.t('active_admin.batch_actions.delete_confirmation', plural_model: "projects") } do |selected_ids|
    Project.destroy_all id: selected_ids
    redirect_to collection_path, :notice => I18n.t("active_admin.batch_actions.succesfully_destroyed", count: selected_ids.count, model: "project", plural_model: "projects")
  end
  
  index do |t|
    selectable_column
    column(:number, sortable: :number) { |project| link_to project.number, project if project.number.present? }
    column(:client, :sortable => :client_id) { |project| link_to truncate(project.client_name, length: 35), client_path(project.client), title: project.client_name }
    column(:name, sortable: :name) { |project| link_to truncate(project.name, length: 35), project_path(project), title: project.name }
    column :product_owner, :sortable => :product_owner_id
    column "" do |project|
      restricted_default_actions_for_resource(project) + link_to("Tickets", project_tickets_path(project))
    end
  end
  
  form :partial => 'form'
  
  show :title => proc { truncate resource.display_name, length: 50 } do
   panel "Project Details" do
      attributes_table_for resource do
        row :number
        row :name
        row :client
        row(:hourly_rate) { number_to_currency resource.hourly_rate } unless current_admin_user.employee?
        row :start_date do
          resource.start_date.humanize
        end
        row :end_date do
          resource.safe_end_date
        end
        row :description do
          resource.description.html_safe
        end
      end
    end
  end
  
  sidebar "Internal / Accounting", :only => [:show] do
    attributes_table_for resource do
      row :owner do
        link_to resource.product_owner.full_name, admin_user_path(resource.product_owner)
      end
      row :completed do
        status_tag resource.completed? ? 'Completed' : 'In Progress', resource.completed? ? :green : :warn
      end
    end
  end
  
  sidebar "Members", :only => [:show] 
  
  sidebar "Project Roadmap", :only => [:roadmap] do
    para "A project roadmap outlines progress for the overall project, and progress for all active milestones so you can easily view the health of the project."
    para strong("Ticket Progress") + text_node("is a health meter to show you what tickets are overdue.")
    para strong("Budget Progress") + text_node("quickly displays whether the project is over or under budget.")
    para strong("Billable vs Non-Billable") + text_node("displays the ratio of billable to non-billable time spent.")
  end
  
  sidebar :project_information, only: :roadmap do
    @project = Project.find_by_url! params[:id]
    @tickets = @project.tickets
    @milestones = @project.milestones
    @num_assignees = @tickets.select(:assignee_id).uniq { |t| t.assignee_id }.count
    @total_hours = @tickets.sum :estimated_time
    render partial: "project_information_sidebar", locals: { tickets: @tickets, milestones: @milestones, num_assignees: @num_assignees, total_hours: @total_hours }
  end
  
  member_action :roadmap do
    redirect_to projects_path, :alert => "Unable to retrieve desired project." if @project.nil?
  end
  
  member_action :whiteboard do
    redirect_to projects_path, alert: "Unable to retrieve desired project.", status: :not_found if @project.nil?
  end
  
  member_action :edit_whiteboard do
    redirect_to projects_path, alert: "Unable to retrieve desired project.", status: :not_found if @project.nil?
  end
  
  member_action :save_whiteboard, method: :put do
    redirect_to projects_path, alert: "Unable to retrieve desired project.", status: :not_found if @project.nil?

    if @project.update_attributes(params[:project])
      redirect_to whiteboard_project_path(@project), notice: "Updated project whiteboard."
    else
      redirect_to whiteboard_project_path(@project), alert: "Failed updating project whiteboard."
    end
  end
  
  member_action :archive do
    unless @project.nil?
      @project.archive!
      redirect_to projects_path, :notice => "Project archived."
    else
      redirect_to projects_path, :alert => "Unable to retrieve desired project."
    end
  end
  
  member_action :unarchive do
    unless @project.nil?
      @project.unarchive!
      redirect_to projects_path, :notice => "Project unarchived."
    else
      redirect_to projects_path, :alert => "Unable to retrieve desired project."
    end
  end
  
  collection_action :switch, method: :post do
    redirect_to project_tickets_path(@project)
  end
  
  controller do
    
    def set_project
      @project = Project.find_by_url! params[:id]
    end
     
  end
  
end