# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :user do
    fullname { [Faker::Name.first_name, Faker::Name.last_name].join(' ') }
    email { Faker::Internet.email }
    avatar_url ""
    password "123456"
    password_confirmation "123456"
  end

  factory :me, class: User do
    fullname "Hongliang Tian"
    email "tatetian@gmail.com"
    avatar_url ""
    password "123456"
    password_confirmation "123456"
  end
end
