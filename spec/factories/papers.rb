# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :paper do
    title "Latent Dirichlet Allocation"
    pub_date Date.new(2003)
    doc_hash "98734iooisadfsajfsai9"  # not determined yet
    uploader_id 1
    club_id 1
  end
end
