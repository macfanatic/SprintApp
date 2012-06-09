ActiveAdmin.register_page "EmployeeTimesheet" do
  
  menu label: "Employee Timesheet", parent: "Reports", if: proc { can? :index, :employee_timesheet }
  
  controller.authorize_resource class: false
  controller.before_filter :employees
  
  page_action :view, method: :post do
    @employee = AdminUser.find params[:employee_id]    
    @start = Date.parse(params[:start]).to_date
    @end = Date.parse(params[:end]).to_date
    @page_title = "Employee Timesheet: #{@employee.full_name}"

    @comments = {}
    (@start..@end).each do |date|
      @comments[date] = TicketComment.created_by(@employee).where("DATE(ticket_comments.created_at) = ? AND ticket_comments.time > 0", date).group(:ticket_id).order(:ticket_id).sum(:time)
    end
    
    @total_time = TicketComment.created_by(@employee).where("DATE(ticket_comments.created_at) BETWEEN ? AND ?", @start, @end).sum(:time)
    
    render layout: 'active_admin'
  end
  
  controller do
    
    def index
      @page_title = 'Employee Timesheet'
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