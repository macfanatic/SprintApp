class TicketComment < ActiveRecord::Base
  
  has_paper_trail
  
  belongs_to :ticket
  belongs_to :version
  
  before_create :set_version
  before_destroy :remove_time
  after_initialize :defaults
  
  validates :time, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  
  scope :billable, includes(:ticket).where(tickets: { billable: true})
  scope :created_by, lambda { |user| includes(:version).where(versions: { whodunnit: user.is_a?(Array) ? user : user.id.to_s }) }
  scope :today, lambda { updated_during(Date.today.beginning_of_day..Date.today.end_of_day) }
  scope :this_week, lambda { updated_during(Sprint.start_date.beginning_of_day..Sprint.end_date.end_of_day) }
  scope :last_week, lambda { updated_during(Sprint.last_week) }
  scope :this_month, lambda { updated_during(Date.today.beginning_of_month.beginning_of_day..Date.today.end_of_month.end_of_day) }
  scope :last_month, lambda { start = Date.today.prev_month.beginning_of_month.beginning_of_day; updated_during(start..(start.end_of_month.end_of_day)) }
  scope :this_year, lambda { updated_during(Date.today.beginning_of_year.beginning_of_day..Date.today.end_of_year.end_of_day) }
  scope :updated_during, lambda { |range| where(created_at: range) }
  
  def time=(t)
    
    # If provided in hh:mm format, convert to hours as decimal format
    if /(\d{1,2}):(\d{2})/ =~ t.to_s
      t = ($1.to_i) + ($2.to_f / 60)
    end
    
    write_attribute :time, t.to_f.round(2)
  end

  private
  
  def defaults
    self.body ||= ""
    self.time ||= 0
  end
  
  def set_version
    new_version = ticket.versions.last rescue nil
    previous_comment = ticket.ticket_comments.where('version_id IS NOT NULL').last
    if previous_comment.nil? || previous_comment.version_id != new_version.id
      self.version_id = new_version.id
    else
      Rails.logger.info "there was not a version object created for the ticket (#{ticket.id}) itself for some reason"
    end
    true
  end
  
  # This method doesn't trigger save callbacks on the associated Ticket model
  def remove_time
    ticket_time = [self.ticket.actual_time - self.time, 0].max
    self.ticket.update_column :actual_time, ticket_time
  end
  
end
