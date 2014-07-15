require 'spec_helper'

describe Address do
  let!(:address) {Address.new(:street => "Fowler Street", :city => "Melbourne", :state => "CA", :zip => 3000)}

  subject{ address }

  it {should respond_to(:street)}
  it {should respond_to(:city)}
  it {should respond_to(:state)}
  it {should respond_to(:zip)}
  it {should respond_to(:addressable_type)}

  it "street can be blank" do
    address.street = ""
    address.should be_valid
  end

  it "city can be blank" do
    address.city = ""
    address.should be_valid
  end

  it "state can be blank" do
    address.state = ""
    address.should be_valid
  end

  it "zip can be blank" do
    address.zip = ""
    address.should be_valid
  end

  it "only allow states defined in 'States Module' " do
    address.state = "AL"
    address.should be_valid
  end

  it "dont allow states to be valid if its not defined in 'States Module'" do
    address.state = "VIC"
    address.should be_invalid
  end

  it "state can not be longer than two character long" do
    address.state = "ALL"
      address.should be_invalid
  end

  it "needs number(numberic) for zip" do
    address.zip = 3000
    address.should be_valid
  end

  it "allows zip to be string if it can be converted to number" do
    address.zip = "4000"
    address.should be_valid
  end

  it "dont allow alphabets for zip" do
    address.zip = "ABC"
    address.should be_invalid
  end

  it "will save valid address to database" do
    expect {
      address.save
    }.to change { Address.count }.by(1)
  end

  describe "#to_s" do
    it "will return full address in format [street,city,state,zip]" do
      my_address = address.to_s
      my_address.should == "Fowler Street, Melbourne,CA 3000"
    end
  end
end