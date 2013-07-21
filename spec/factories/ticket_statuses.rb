FactoryGirl.define do
  factory :ticket_status do
    sequence(:name) { |n| "Status #{n}" }
  end
end
