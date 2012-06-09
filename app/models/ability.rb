class Ability
  include CanCan::Ability
  
  def initialize(user)
    
    return if user.nil?
        
    can :batch_action, :all
    
    if user.admin?
      
      can [:manage, :switch], [AdminUser, Client, Team, TicketCategory, TicketStatus, TicketPriority, Project]
      
      can :create, Contact
      can [:index, :update, :read, :view, :destroy], Contact
      
      can :manual_punch, TicketComment
      
      cannot :index, [Ticket, Milestone]
      can [:create, :advanced_edit, :move], [Ticket, Milestone]
      can [:index, :update, :read, :view, :destroy, :start_timer, :stop_timer, :ticket_time, :update_comment, :edit_multiple], Ticket
      can [:index, :update, :read, :view, :destroy, :revive, :complete, :roadmap], Milestone
            
      can :manage, ProjectFile
            
      can [:index, :view], [:employee_timesheet, :company_roadmap, :project_report, :ticket_report, :hours_worked_report]
            
    elsif user.employee?
      
      can [:edit, :update, :change_password, :process_password_change, :profile], AdminUser, :id => user.id
      
      cannot :index, [AdminUser, Client, TicketCategory, TicketPriority, TicketStatus, Team]
      
      # can :manual_punch, TicketComment if account.allow_manual_punches?
      
      cannot [:manage, :index], [Project, Ticket, Milestone]
      can [:index, :view, :read, :roadmap, :whiteboard, :edit_whiteboard, :save_whiteboard, :switch], Project, :id => user.project_ids      
      can [:index, :view, :read, :roadmap], Milestone
      can [:index, :read, :view, :update, :start_timer, :stop_timer, :ticket_time], Ticket, :id => user.projects.ticket_ids
      can [:index, :read, :view], AdminUser
      
      can :manage, ProjectFile
                  
    end
    
  end
  
end
