# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :metadata, :class => 'Metadata' do
    uuid "sjdio9i09jioasdf90jisadf"
    title "Latent Dirichlet Allocation"
    pub_date "2012-08-22"
    num_pages 1
  end
end
