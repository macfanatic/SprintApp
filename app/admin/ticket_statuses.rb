ActiveAdmin.register TicketStatus, :sort_order => 'name_asc' do
  
  # for use with cancan
  controller.authorize_resource
  
  menu :parent => "Administration", :if => proc { can?( :manage, TicketStatus ) }
    
  filter :name
  filter :created_at
  filter :updated_at
  
  scope :all, :default => true
  scope(:open) { |statuses| statuses.active }
  scope(:closed) { |statuses| statuses.closed }
  
  index do |t|
    selectable_column
    column(:name, sortable: :name) { |item| link_to truncate(item.name, length: 35), item, title: item.name }
    column 'Open Status', :sortable => :active do |status|
      status_tag status.active? ? "Active" : "Closed", status.active? ? :green : :red
    end
    restricted_actions_column(t)
  end
  
  form :partial => "form"
  
  show :title => :name do
    panel "Status Details" do
      attributes_table_for resource do
        row :name
      end
    end
  end
  
end
