shared_examples "addressable" do

  it { should have_one :address }
  its(:address) { should_not be_nil }

end
