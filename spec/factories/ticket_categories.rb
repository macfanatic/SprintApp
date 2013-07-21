FactoryGirl.define do
  factory :ticket_category do
    sequence(:name) { |n| "Category #{n}" }
  end
end
