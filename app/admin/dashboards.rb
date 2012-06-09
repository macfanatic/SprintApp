ActiveAdmin::Dashboards.build do
  
  ###################################  
  # Welcome widgets
  ###################################
  
  section "Welcome to SprintApp", :if => proc { current_admin_user.new_user? } do
    current_admin_user.welcome!
    text_node(render "dashboard/welcome")
  end
  

  ###################################  
  # Account level dashboard widgets
  ###################################
  
  section "My Sprint", :priority => 1, :if => proc { current_admin_user.welcomed? } do
    table_for Ticket.owned_by(current_admin_user).current_sprint do |attr_table|
      render "dashboard/tickets", :context => self
    end
  end
  
  section "My Stats", priority: 2, if: proc { current_admin_user.welcomed? } do
    text_node( render "shared/user_statistics", user: current_admin_user )    
  end
  
  section "My Late Tickets", :if => proc { current_admin_user.employee? and current_admin_user.welcomed? }, :priority => 3 do
    table_for Ticket.overdue.owned_by(current_admin_user) do |attr_table|
      render "dashboard/tickets", :context => self
    end
  end
  
  # This is global late tickets, only shown to admins
  section "Late Tickets", :if => proc { current_admin_user.admin? and current_admin_user.welcomed? }, :priority => 3 do
    table_for Ticket.overdue do |attr_table|
      render "dashboard/tickets", :context => self
    end
  end
  
  section "My New Tickets", :priority => 4, :if => proc { current_admin_user.welcomed? } do
    table_for Ticket.recent.owned_by(current_admin_user) do |attr_table|
      render "dashboard/tickets", :context => self
    end
  end
  
  section "Watched Tickets", :priority => 5, :if => proc { current_admin_user.welcomed? } do
    table_for Ticket.active.watched(current_admin_user) do |attr_table|
      render "dashboard/tickets", :context => self
    end
  end
  
  section "Projects I Own", :if => proc { current_admin_user.admin? and current_admin_user.welcomed? }, :priority => 20 do
    table_for Project.owned_by(current_admin_user) do |attr_table|
      render "dashboard/projects", :context => self
    end
  end
  
  section "Recent Projects", :if => proc { current_admin_user.admin? and current_admin_user.welcomed? }, :priority => 25 do
    table_for Project.except(:order).recent do |attr_table|
      render "dashboard/projects", :context => self
    end
  end

end