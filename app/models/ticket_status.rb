class TicketStatus < ActiveRecord::Base
  
  has_many :tickets
  
  validates :name, :presence => true
  
  default_scope order("lower(name) asc")
  
  scope :active, where("active = ?", true)
  scope :closed, where("active = ?", false)
  
end
