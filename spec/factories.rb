FactoryGirl.define do
  factory :person do
    sequence(:name) { |i| "Person ##{i}" }
    slug { SecureRandom.uuid }
  end

  factory :company do
    sequence(:name) { |i| "Company ##{i}" }
    slug { SecureRandom.uuid }
  end
end
