FactoryGirl.define do
  factory :team do
  	sequence(:name) { |n| "Team #{n}" }
  end
end
