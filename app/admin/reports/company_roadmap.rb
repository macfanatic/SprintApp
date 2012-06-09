ActiveAdmin.register_page "CompanyRoadmap" do
  
  menu label: "Company Roadmap", parent: "Reports", if: proc { can? :index, :company_roadmap }
  
  controller.authorize_resource class: false
  
  sidebar :company_roadmap_help do
    para "The company roadmap report shows you the health of all open projects for your organization."
    para "Use this information to quickly determine how your organization as a whole."
  end
  
  controller do
    
    def index
      @page_title = 'Company Roadmap'
      @projects = Project.active
      render layout: 'active_admin'
    end
    
  end
  
end