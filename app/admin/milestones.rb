ActiveAdmin.register Milestone, :sort_order => "start_date_asc" do
  
  # for use with cancan
  controller.authorize_resource
  controller.resources_configuration[:self][:finder] = :find_by_url!
  
  belongs_to :project, finder: :find_by_url!
  
  filter :name
  filter :start_date
  filter :end_date
  filter :description
  filter :created_at
  filter :updated_at
  
  scope :all
  scope :active, :default => true
  scope :closed
  
  action_item :only => :show do
    link_to "Roadmap", roadmap_project_milestone_path(resource)
  end
  
  batch_action :destroy, { if: proc{ can? :destroy, Milestone }, priority: 100, confirm: I18n.t('active_admin.batch_actions.delete_confirmation', plural_model: "milestones") } do |selected_ids|
    Milestone.destroy_all id: selected_ids
    redirect_to collection_path, :notice => I18n.t("active_admin.batch_actions.succesfully_destroyed", count: selected_ids.count, model: "milestone", plural_model: "milestones")
  end
  
  index do |t|
    selectable_column
    column(:name, sortable: :name) { |m| link_to m.name, [m.project, m] }
    column "Start Date", :sortable => :start_date do |milestone|
      milestone.start_date.humanize
    end
    column "End Date", :sortable => :end_date do |milestone|
      milestone.safe_end_date
    end
    column "Completion" do |milestone|
      milestone_progress_indicator(milestone, false)
    end
    column "Budget" do |milestone|
      milestone_budget_progress_indicator(milestone, false)
    end
    column "" do |milestone|
      actions = restricted_default_actions_for_resource(milestone)
      if can?(:complete, milestone)
        if milestone.completed?
          actions += link_to( "Revive", revive_project_milestone_path(milestone.project, milestone), confirm: "Are you sure you want to revive this milestone?" )
        else
          actions += link_to( "Complete", complete_project_milestone_path(milestone.project, milestone), confirm: "Are you sure you want to complete this milestone?" )
        end
      end
      actions
    end
  end
  
  form :html => { :class => "filter_form consolidated_form" } do |f|
    f.inputs "Milestone", :class => "inputs consolidated" do
      f.input :name
      f.input :start_date, :label => "Start Date", :as => :datepicker, :wrapper_html => { :class => "filter_form_field filter_date_range field-row" }
      f.input :end_date, :label => "End Date", :as => :datepicker, :wrapper_html => { :class => "filter_form_field filter_date_range field-row" }
      f.input :description, :input_html => { class: :ckeditor }, :wrapper_html => { :class => "cleared" }
    end
    f.buttons
  end
  
  show :title => :name do
    panel "Milestone" do
      attributes_table_for resource do
        row :name
        row :start_date
        row :end_date
        row :completed
        row :description do 
          resource.description.html_safe rescue nil
        end
      end
    end
  end
  
  sidebar "Milestone Roadmap", :only => [:roadmap] do
    para "A milestone roadmap outlines progress for the milestone, as determined from the tickets belonging to this milestone."
    para strong("Ticket Progress") + text_node("is a health meter illustrating ticket completion progress. More green means you're ahead of schedule, while red means you are behind.")
    para strong("Budget Progress") + text_node("quickly displays whether the milestone is over or under budget.")
    para strong("Billable vs Non-Billable") + text_node("displays the ratio of billable to non-billable time spent.")
  end
  
  member_action :roadmap do
    @milestone = Milestone.find_by_url!(params[:id], :include => [:project, :tickets]) rescue nil
    redirect_to(project_milestones_path(params[:project_id]), :alert => "Could not locate desired milestone.") if @milestone.nil?
  end
  
  member_action :complete do
    @milestone = Milestone.find_by_url!(params[:id]) rescue nil
    unless @milestone.nil? 
      @milestone.completed = true
      @milestone.save
      redirect_to project_milestones_path(@milestone.project), :notice => "Milestone succesfully completed."
    else
      redirect_to project_milestones_path(params[:project_id]), :alert => "Could not locate desired milestone."
    end
  end
  
  member_action :revive do
    @milestone = Milestone.find_by_url!(params[:id]) rescue nil
    unless @milestone.nil?
      @milestone.completed = false
      @milestone.save
      redirect_to project_milestones_path(@milestone.project), :notice => "Milestone succesfully resurrected."
    else
      redirect_to project_milestones_path(params[:project_id]), :alert => "Could not locate desired milestone."
    end
  end
  
  controller do
    def end_of_association_chain
      super.except(:order)
    end
  end
  
end
