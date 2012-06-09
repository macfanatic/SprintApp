module TicketsHelper

  def ticket_billable_status_tag(ticket)
    color = ticket.billable? ? :green : :warn
    sprintapp_status_tag ticket.billable? ? "YES" : "NO", color
  end

  def health_tag_for_ticket(ticket)
    percentage = ((ticket.actual_time.to_f / ticket.estimated_time.to_f) * 100).round rescue 0
    percentage = [100, percentage].min
    if percentage == 100
      color = :red
      title = "Over Budget"
    elsif percentage >= 95
      color = :red
      title = "Almost Over"
    elsif percentage >= 65
      color = :orange
      title = "Watch Closely"
    else
      color = :green
      title = "Great"
    end
    sprintapp_status_tag title, color
  end

  def status_tag_for_ticket_status(ticket)
    active = ticket.status.active?
    color = active ? :green : :none
    sprintapp_status_tag ticket_status(ticket), color  
  end

  def priority_tag_for_ticket(ticket)
    sprintapp_status_tag ticket_priority(ticket), color_for_weight(ticket.priority)
  end

  def color_for_weight(weight)
    case weight
     when 'low'
      :blue
    when 'normal'
      :none
    when 'high'
      :orange
    when 'immediate'
      :red
    end
  end

  def status_tag_for_ticket_by_due_date(ticket)
    unless ticket.end_date.nil?
      if ticket.end_date < Date.today
        if ticket.end_date >= 4.days.ago.to_date
          color = :orange
        else
          color = :red
        end
      else 
        color = :none
      end
      color = :green if !ticket.status.active?    
      sprintapp_status_tag(ticket.safe_end_date, color)
    else
      sprintapp_status_tag('N/A', nil)
    end
  end

  def colorize_ticket_by_start_date(ticket)
    is_open = ticket.status.active?
    if is_open 
      if ticket.start_date > Date.today
        :none
      elsif ticket.start_date == Date.today
        :orange
      else
        :red
      end
    else
      :none
    end
  end

  def ticket_status(ticket)
    ticket.status.name rescue 'None'
  end

  def ticket_priority(ticket)
    ticket.ticket_priority.name rescue 'None'
  end

  def ticket_assignee(ticket)
    ticket.assignee.full_name rescue 'None'
  end

  def ticket_category(ticket)
    ticket.ticket_category.name rescue 'None'
  end

  def ticket_milestone(ticket)
    ticket.milestone.name rescue 'None'
  end

  def email_qualified_name(ticket)
    "[%s - %s #%d] %s" % [truncate(ticket.project.name, :length => 35), ticket.ticket_category.name, ticket.number, truncate(ticket.name, :length => 75)]
  end

  def formatted_changeset(ticket)
    formatted_changeset_for_version(ticket.versions.last)
  end

  def formatted_changeset_for_version(version)
    return [] if version.nil? 
    changes = []
    changeset = version.changeset rescue nil
    unless changeset.nil?
      changeset.each do |attr, before_after|
        if /.*_id/ =~ attr
          pretty_attr = attr.gsub(/_id/, '').titleize
          pretty_attr.gsub!(' ', '')
        
          klass = if pretty_attr == "Assignee"
            AdminUser
          elsif pretty_attr == "Status"
            TicketStatus
          else
            pretty_attr.constantize rescue return changes
          end

          old_val = klass.find(before_after.first).name rescue 'Unknown'
          new_val = klass.find(before_after.last).name rescue 'Unknown'
          changes << "<strong>#{pretty_attr.titleize}</strong> changed from <em>#{old_val}</em> to <em>#{new_val}</em>."
        else
          unless attr == "description"        
            if before_after.first.nil?
              changes << "<strong>#{attr.titleize}</strong> was set to <em>#{better_format(before_after.last)}</em>."
            elsif before_after.last.nil?
              changes << "<strong>#{attr.titleize}</strong> was removed."
            else
              changes << "<strong>#{attr.titleize}</strong> changed from <em>#{better_format(before_after.first)} to #{better_format(before_after.last)}</em>."
            end
          else
            changes << "<em>Description updated</em>."
          end
        end
      end
    end
    changes
  end

  def update_or_create_tag_for_version(version)
    version.event == 'create' ? 'created by' : 'updated by'
  end
  
end