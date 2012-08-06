# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    fullname "Tate Tian"
    sequence(:email) { |n| "tatetian#{n}@gmail.com" }
    avatar_url ""
  end
end
