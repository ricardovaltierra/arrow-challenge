FactoryBot.define do
  factory :arrow do
    description { |description| description || Faker::Lorem.paragraph }
    owner_id { factory :user }
    author_id { factory :user }
  end
end
