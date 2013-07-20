require 'spec_helper'

describe Team do

  it { should validate_presence_of :name }
  it { should have_and_belong_to_many :admin_users }
  it { should have_many(:tickets).through(:admin_users) }

  describe '#display_name' do
    subject(:team) { build(:team, name: 'my team') }
    its(:display_name) { should == 'my team' }
  end

end
