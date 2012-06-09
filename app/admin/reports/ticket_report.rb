ActiveAdmin.register_page "TicketReport" do
  
  menu label: "Ticket Report", parent: "Reports", if: proc { can? :index, :ticket_report }
  controller.authorize_resource class: false, except: :tickets
  controller.before_filter :projects
  
  page_action :view, method: :post do
    @ticket = Ticket.find params[:ticket_id]    
    @start = Date.parse(params[:start]).to_date
    @end = Date.parse(params[:end]).to_date
    @page_title = "Ticket Report: #{@ticket.long_name}"

    @comments = {}
    (@start..@end).each do |date|
      @comments[date] = TicketComment.where(ticket_id: params[:ticket_id]).where("DATE(ticket_comments.created_at) = ? AND ticket_comments.time > 0", date).includes(:version).group("versions.whodunnit").sum(:time)
    end
        
    @total_time = TicketComment.where(ticket_id: params[:ticket_id]).where("DATE(ticket_comments.created_at) BETWEEN ? AND ?", @start, @end).sum(:time)
    
    render layout: 'active_admin'
  end
  
  page_action :tickets, method: :post do
    respond_to do |format|
      format.js
    end
  end
  
  controller do
    
    def index
      @page_title = 'Ticket Report'
      params[:start] ||= Sprint.start_date
      params[:end] ||= Sprint.end_date
      render layout: 'active_admin'
    end
    
    private
      
      def projects
        @tickets = Project.find(params[:project_id]).tickets rescue []
        @projects = Project.all
      end
    
  end
  
end