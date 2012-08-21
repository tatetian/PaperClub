# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    club_id 1
    invitor_id 1
    invitee_email "tatetian@gmail.com"
    role "member"
    token "18usadfjoisadf09i09j"
  end
end
