class Client < ActiveRecord::Base

  include Addressable

  has_many :projects, :dependent => :nullify
  has_many :contacts, :dependent => :destroy
  
  validates :name, :presence => true
  validates :hourly_rate, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  
  scope :sorted, order("lower(clients.name) asc")
  default_scope order("lower(clients.name) asc")
  
  acts_as_url :name, limit: 100
  
  def display_name
    name
  end
  
  def to_param
    url
  end
  
end
