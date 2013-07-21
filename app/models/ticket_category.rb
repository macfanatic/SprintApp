class TicketCategory < ActiveRecord::Base
  
  has_many :tickets, :dependent => :nullify
  
  default_scope order("lower(name) asc")
  
  validates :name, :presence => true, uniqueness: true
  
  def display_name
    name
  end
  
end
