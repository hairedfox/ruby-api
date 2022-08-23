require 'faker'

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    ip_address { Faker::Internet.unique.ip_v4_address }
  end
end
