class NotificationObserver < ActiveRecord::Observer
  
  observe Ticket
  
  def after_save(ticket)
    
    # Want to avoid sending an email if a version wasn't even created, b/c obvisouly nothing important happened
    version = ticket.versions.where("created_at >= ?", 3.seconds.ago).first
    unless version.nil?
      recipients = notification_distribution_list(ticket, version)
      TicketMailer.notification_email(ticket, recipients, version).deliver unless recipients.empty? || notification_from_timer?(ticket, version)
    end
    
  end
  
  private 
  
  def notification_distribution_list(ticket, version)
    modified_by_email = AdminUser.find(version.whodunnit).email rescue nil
    list = (ticket.watchers.active.pluck(:email) + [ticket.assignee_email]).uniq
    list.delete_if { |email| email.nil? or email == modified_by_email }
  end
  
  def notification_from_timer?(ticket, version)
    return false if version.nil?
    changes = version.changeset
    return changes.keys.include?("actual_time") && changes.keys.count == 1
  end
  
end
