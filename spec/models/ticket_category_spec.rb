require 'spec_helper'

describe TicketCategory do

  it { should have_many :tickets }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe '#display_name' do
    subject(:category) { build(:ticket_category) }
    its(:display_name) { should == category.name }
  end

end
