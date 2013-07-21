FactoryGirl.define do
  factory :project do
    association :client
    association :product_owner, factory: :admin_user
    sequence(:name) { |n| "Project #{n}" }
    start_date { Date.today }
    members { [create(:employee)] }
  end
end
