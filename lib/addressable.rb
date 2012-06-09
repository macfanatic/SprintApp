module Addressable
  extend ActiveSupport::Concern
  
  included do
    
    has_one :address, :as => :addressable, :dependent => :destroy
    accepts_nested_attributes_for :address
    delegate :address, :city, :state, :zip, :to => :address, :prefix => true
    
    after_initialize :init_address
    
    delegate :address, :to => :address, :prefix => true, :allow_nil => true
    
  end
  
  def init_address
    self.address ||= Address.new if new_record?
  end
  
end