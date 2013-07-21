shared_examples "phoneable" do |attribute|
  it { should_not allow_value("1abc").for(attribute) }
  it { should allow_value("123.4567").for(attribute) }
  it { should allow_value("123.123.4567").for(attribute) }
  it { should allow_value("(123)-123.4567").for(attribute) }
end
