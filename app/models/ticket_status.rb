class TicketStatus < ActiveRecord::Base
  
  has_many :tickets, foreign_key: :status_id
  
  validates :name, :presence => true, uniqueness: true
  
  default_scope order("lower(name) asc")
  
  scope :active, -> { where active: true }
  scope :closed, -> { where active: false }
  
end
