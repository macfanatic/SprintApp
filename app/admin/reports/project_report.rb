ActiveAdmin.register_page "ProjectReport" do
  
  menu label: "Project Report", parent: "Reports", if: proc { can? :index, :project_report }
  controller.authorize_resource class: false
  controller.before_filter :projects
  
  page_action :view, method: :post do
    @project = Project.find params[:project_id]    
    @start = Date.parse(params[:start]).to_date
    @end = Date.parse(params[:end]).to_date
    @page_title = "Project Report: #{@project.display_name}"

    @comments = {}
    (@start..@end).each do |date|
      @comments[date] = TicketComment.includes(:ticket).where(tickets: { project_id: params[:project_id] }).where("DATE(ticket_comments.created_at) = ? AND ticket_comments.time > 0", date).group(:ticket_id).order(:ticket_id).sum(:time)
    end
    
    @total_time = TicketComment.includes(:ticket).where(tickets: { project_id: params[:project_id] }).where("DATE(ticket_comments.created_at) BETWEEN ? AND ?", @start, @end).sum(:time)
    
    render layout: 'active_admin'
  end
  
  controller do
    
    def index
      @page_title = 'Project Report'
      params[:start] ||= Sprint.start_date
      params[:end] ||= Sprint.end_date
      render layout: 'active_admin'
    end
    
    private
      
      def projects
        @projects = Project.all
      end
    
  end
  
end