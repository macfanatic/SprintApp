FactoryGirl.define do
  factory :contact do
  	sequence(:name) { |n| "Contact #{n}" }
  	email { Faker::Internet.email }
  	phone { "123.123.1233" }
  end
end
