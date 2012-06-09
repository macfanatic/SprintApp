class TicketMailer < ActionMailer::Base
  
  default from: "notifications@sprintapp.com"
  helper ApplicationHelper
  helper TicketsHelper
  helper AdminHelper
  layout "mailer"
  
  def notification_email(ticket, distribution_list, version)
    @ticket = ticket
    @version = version
    mail(:to => distribution_list, :subject => email_subject)
  end
  
  private
  
  def email_subject
    "[%s - %s #%d](%s) %s" % [@ticket.project.name, @ticket.ticket_category.name, @ticket.number, @ticket.status.name, @ticket.name]
  end
  
end
