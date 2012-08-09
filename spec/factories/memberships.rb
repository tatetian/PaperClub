# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership do
    role "admin"
    upload_tag_id 1
    club_id 1
    user_id 1
  end
end
