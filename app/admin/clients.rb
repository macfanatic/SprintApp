ActiveAdmin.register Client, :sort_order => "name_asc" do
  
  # for use with cancan
  controller.authorize_resource
  controller.resources_configuration[:self][:finder] = :find_by_url!
  
  menu :parent => "Administration", :if => proc { can?( :manage, Client) }
    
  filter :name
  filter :created_at
  filter :updated_at
  
  action_item :only => [:show] do
    link_to "Contacts", client_contacts_path( resource )
  end
  
  index do |t|
    selectable_column
    column(:name, sortable: :name) { |client| link_to truncate(client.name, length: 35), client, title: client.name }
    column "Created", :sortable => :created_at do |client|
      client.created_at.humanize
    end
    column "Updated", :sortable => :updated_at do |client|
      client.updated_at.humanize
    end
    column "" do |client|
      restricted_default_actions_for_resource(client) + link_to( "Contacts", client_contacts_path(client), :class => "member_link" )
    end
  end
  
  form :partial => "form"
  
  show :title => :name do
    
    panel "Client Details" do
      attributes_table_for resource do
        row :name
        row(:hourly_rate) { number_to_currency resource.hourly_rate }
        row :created_at do
          resource.created_at.humanize
        end
        row :updated_at do
          resource.updated_at.humanize
        end
      end
    end
    
    text_node(render :partial => "addresses/show", :locals => { :address => resource.address })
    
  end
  
end
