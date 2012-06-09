class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true
  
  validates :state, :inclusion => { :in => States::all.keys }, :allow_blank => true
  validates :zip, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true

  def to_s
    "%s, %s,%s %s" % [street,city,state,zip]
  end
  
end
