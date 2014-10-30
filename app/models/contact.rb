class Contact < ActiveRecord::Base
  
  belongs_to :client
  has_many :projects, :through => :client
  
  include Addressable
  
  validates :name, :presence => true
  validates :email, email: true, presence: true
  
  validates :phone, presence: true
  validates :phone, format: { with: /\d{7,10}/, message: "not a valid phone number" }, if: ->(contact) { contact.phone.present? }
  validates :cell, format: { with: /\d{7,10}/, message: "not a valid phone number" }, allow_blank: true
      
  def phone=(val)
    write_attribute :phone, val.to_s.gsub(/[^0-9]*/, '')
  end
  
  def cell=(val)
    write_attribute :cell, val.to_s.gsub(/[^0-9]*/, '')
  end
  
end
