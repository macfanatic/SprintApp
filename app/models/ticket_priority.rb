class TicketPriority < ActiveRecord::Base
  
  WEIGHTS = %w(low normal high immediate).freeze
  
  has_many :tickets
  
  default_scope order("lower(name) asc")
  
  validates :name, presence: true, uniqueness: true
  validates :weight, presence: true, inclusion: { in: WEIGHTS }
  
end
