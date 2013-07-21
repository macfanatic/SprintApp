FactoryGirl.define do
  factory :ticket_priority do
    sequence(:name) { |n| "Priority: #{n}"}
    weight { 'normal' }
  end
end
