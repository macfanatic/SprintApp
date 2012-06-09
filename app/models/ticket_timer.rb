class TicketTimer < ActiveRecord::Base
  
  belongs_to :admin_user
  belongs_to :ticket
  has_one :project, through: :ticket
  
  scope :created_by, lambda { |user| where admin_user_id: user.id }
  
  def elapsed_time
    Time.zone.now - created_at.to_time
  end
  
  def readable_elapsed
    Time.at(elapsed_time).utc.strftime "%H:%M" rescue nil
  end
  
end
