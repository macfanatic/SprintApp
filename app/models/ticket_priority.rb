class TicketPriority < ActiveRecord::Base
  
  WEIGHTS = %w(low normal high immediate)
  
  has_many :tickets
  
  default_scope order("lower(name) asc")
  
  validates :name, :presence => true
  validates :weight, :presence => true, :inclusion => { :in => WEIGHTS }
  
end
