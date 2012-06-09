ActiveAdmin.register TicketCategory, :sort_order => "name_asc" do
  
  # for use with cancan
  controller.authorize_resource
  
  menu :parent => "Administration", :if => proc { can?( :manage, TicketCategory ) }
    
  filter :name
  filter :created_at
  filter :updated_at
  
  index do |t|
    selectable_column
    column(:name, sortable: :name) { |item| link_to truncate(item.name, length: 35), item, title: item.name }
    restricted_actions_column(t)
  end
  
  form :partial => "form"
  
  show :title => :display_name do
    panel "Priority Details" do
      attributes_table_for resource do
        row :name
      end
    end
  end
  
end
