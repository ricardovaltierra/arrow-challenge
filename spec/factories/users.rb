FactoryBot.define do
  factory :user do
    sequence(:name) { |last| "mr. #{last}" }
    sequence(:email)  { |number| "mail_n_#{number}@mail.com" }
    password { '123456' }
    password_confirmation { '123456' }
  end
end
