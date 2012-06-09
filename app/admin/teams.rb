ActiveAdmin.register Team, :sort_order => "name_asc" do
  
  controller.authorize_resource
  
  menu :parent => "Administration", :if => proc { can?(:index, Team) }
    
  filter :name
  filter :description
  filter :created_at
  filter :updated_at
  
  index do
    selectable_column
    column(:name, :sortable => :name) { |team| link_to team.name, team }
    column("Created", :sortable => :created_at) { |team| team.created_at.humanize }
    column("Updated", :sortable => :updated_at) { |team| team.updated_at.humanize }
    default_actions
  end
  
  show :title => :name do
    panel "Team Details" do
      attributes_table_for resource do
        row :name
        row :description
        row "Members" do
          raw(resource.admin_users.collect { |user| link_to user.full_name, user }.join(", "))
        end
      end
    end
  end
  
  form :partial => "form"
  
end
