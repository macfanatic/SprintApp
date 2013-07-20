FactoryGirl.define do
  factory :client do
    sequence(:name) { |i| "client-#{i}" }
    hourly_rate { 0 }
  end
end
