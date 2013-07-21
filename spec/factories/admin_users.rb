FactoryGirl.define do
  factory :admin_user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    role { 'admin' }

    factory :employee do
      role { 'employee' }
    end
  end
end
