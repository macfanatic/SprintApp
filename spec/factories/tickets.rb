FactoryGirl.define do
  factory :ticket do
  	project
  	ticket_priority
  	ticket_category
    association :status, factory: :ticket_status

    sequence(:name) { |n| "Ticket #{n}" }
    description { Faker::Lorem.paragraph }
  end
end
