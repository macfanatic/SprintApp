class Team < ActiveRecord::Base
  
  validates :name, :presence => true
  
  has_and_belongs_to_many :admin_users
  has_many :tickets, :through => :admin_users
  
  default_scope order("lower(name) asc")
  
  def display_name
    name
  end
  
end
