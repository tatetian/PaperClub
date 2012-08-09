# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    content "This is a note." * 50
    position "{left:25, top:50}"
    user_id 1
    paper_id 1
  end
end
