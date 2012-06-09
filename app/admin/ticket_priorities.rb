ActiveAdmin.register TicketPriority, :sort_order => "name_asc" do
  
  # for use with cancan
  controller.authorize_resource
  
  menu :parent => "Administration", :if => proc { can?( :manage, TicketPriority ) }
    
  filter :name
  filter :weight, :as => :select, :collection => TicketPriority::WEIGHTS, :member_label => :titleize
  
  index do |t|
    selectable_column
    column(:name, sortable: :name) { |item| link_to truncate(item.name, length: 35), item, title: item.name }
    column("Weight", :sortable => :weight) { |priority| status_tag(priority.weight, color_for_weight(priority.weight)) }
    restricted_actions_column(t)
  end
  
  form :partial => "form"
  
  show :title => :name do
    panel "Priority Details" do
      attributes_table_for resource do
        row :name
        row("Weight") { status_tag(resource.weight, color_for_weight(resource.weight)) }
      end
    end
  end
  
end
