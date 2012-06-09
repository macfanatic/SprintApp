ActiveAdmin.register_page "HoursWorkedReport" do
  
  menu label: "Hours Worked Report", parent: "Reports", if: proc { can? :index, :hours_worked_report }
  
  controller.authorize_resource class: false
  controller.before_filter :employees
  
  page_action :view, method: :post do
    @selected_employees = AdminUser.find params[:employee_id]
    @start = Date.parse(params[:start]).to_date
    @end = Date.parse(params[:end]).to_date
    @page_title = "Hours Worked Report"

    @comments = {}
    (@start..@end).each do |date|
      @comments[date] = TicketComment.created_by(params[:employee_id]).where("DATE(ticket_comments.created_at) = ? AND ticket_comments.time > 0", date).joins("LEFT OUTER JOIN versions ON versions.id = ticket_comments.version_id LEFT OUTER JOIN admin_users ON CAST(versions.whodunnit as INTEGER) = admin_users.id").order("lower(admin_users.first_name) asc, lower(admin_users.last_name) asc").group("admin_users.first_name, admin_users.last_name, versions.whodunnit").sum(:time)
    end
    
    @total_time = TicketComment.created_by(params[:employee_id]).where("DATE(ticket_comments.created_at) BETWEEN ? AND ?", @start, @end).sum(:time)
    
    render layout: 'active_admin'
  end
  
  controller do
    
    def index
      @page_title = 'Hours Worked Report'
      params[:start] ||= Sprint.start_date
      params[:end] ||= Sprint.end_date
      render layout: 'active_admin'
    end
    
    private
      
      def employees
        @employees = AdminUser.active.reorder("lower(last_name), lower(first_name)")
      end
    
  end
  
end