require 'spec_helper'

describe Contact do
  
  it_behaves_like "addressable"
  it { should belong_to :client }
  it { should have_many(:projects).through(:client) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :email }

  context 'email validation' do
    it { should allow_value(Faker::Internet.email).for(:email) }
    it { should_not allow_value('invalid').for(:email) }
  end

  context 'phone validation' do
    it { should validate_presence_of :phone }
    it_behaves_like "phoneable", :phone
    it_behaves_like "phoneable", :cell
  end

end
