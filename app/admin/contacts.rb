ActiveAdmin.register Contact, :sort_order => "name_asc" do
  
  # for use with cancan
  controller.authorize_resource
  
  belongs_to :client, finder: :find_by_url!
  
  filter :name
  filter :email
  filter :phone
  filter :created_at
  filter :updated_at
  
  index do |t|
    selectable_column
    column :name
    column :email, :sortable => :email do |contact|
      link_to contact.email, "mailto:#{contact.email}"
    end
    column(:phone, sortable: :phone) { |contact| number_to_phone contact.phone }
    column(:cell, sortable: :cell) { |contact| number_to_phone contact.cell }
    column "Created", :sortable => :created_at do |client|
      client.created_at.humanize
    end
    restricted_actions_column(t)
  end
  
  show :title => :name do
    
    panel "Contact Details" do
      attributes_table_for resource do
        row :name
        row(:phone) { number_to_phone resource.phone }
        row(:cell) { number_to_phone resource.cell }
        row :email
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
  
  form :partial => "form"
  
end
