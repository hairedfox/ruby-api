require 'sequel'
require 'dotenv/load'
require 'faker'

Dotenv.load
DB = Sequel.connect(ENV['DB_URL'])

users = DB[:users]
posts = DB[:posts]
rating = DB[:ratings]
feedbacks = DB[:feedbacks]

[:ratings, :posts, :feedbacks, :users].each do |table|
  DB.run "DELETE FROM #{table};"
end

# 50 unique ips
ip_addresses = []

50.times do
  ip_addresses << Faker::Internet.unique.ip_v4_address
end

# 100 users
user_data = []

100.times do |i|
  index = i / 2
  ip_address = ip_addresses[index]
  user_data << [Faker::Internet.unique.username, ip_address]
end

users.import([:username, :ip_address], user_data)

# 200k posts

user_records = users.all

10.times do
  post_data = []

  20_000.times do
    user = user_records.sample
    post_data << [
      Faker::Lorem.sentence,
      Faker::Lorem.sentence,
      user[:id],
      user[:ip_address]
    ]
  end

  posts.import([:title, :content, :user_id, :author_ip_address], post_data)
end


# 10k post feedback
feedback_post_data = []

post_records = posts.limit(10_000).all

post_records.each do |post|
  feedback_post_data << [
    Faker::Lorem.sentence,
    post[:id],
    'Post',
    user_records.sample[:id]
  ]
end

feedbacks.import([:comment, :target_id, :target_type, :user_id], feedback_post_data)

# 50 user feedback with random text
feedback_user_data = []

user_records[0..49].each_with_index do |user, index|
  check_index = index + 50
  feedback_user_data << [
    Faker::Lorem.sentence,
    user_records[check_index][:id],
    'User',
    user[:id]
  ]
end

feedbacks.import([:comment, :target_id, :target_type, :user_id], feedback_user_data)
