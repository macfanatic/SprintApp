require 'spec_helper'

describe Client do

  it_behaves_like "addressable"
  
  it { should have_many :projects }
  it { should have_many :contacts }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe '#hourly_rate' do
    it { should validate_presence_of :hourly_rate }
    it { should allow_value(0).for(:hourly_rate) }
    it { should allow_value(55.50).for(:hourly_rate) }
    it { should_not allow_value(-10).for(:hourly_rate) }
  end

end
