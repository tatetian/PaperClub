# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reply do
    content "Reply to the note"
    user_id 1
    note_id 1
  end
end
