# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :news do
    paper_id 1
    user_id 1
    action "uploaded"
    detail ""
  end
end
