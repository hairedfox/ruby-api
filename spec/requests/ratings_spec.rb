require 'rack'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/authentications_controller.rb'
require_relative '../../app/controllers/ratings_controller.rb'
require_relative '../../app/models/user.rb'
require_relative '../../app/models/post.rb'
require_relative '../../app/models/rating.rb'

RSpec.describe RatingsController, type: :request do
  let(:user) do
    user = User.new(
      username: Faker::Internet.unique.username,
      ip_address: Faker::Internet.unique.ip_v4_address
    )

    user.save

    User.find_by_username(user.username)
  end

  let(:first_post) do
    post = Post.new(
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph,
      user_id: user[:id],
      author_ip_address: user[:ip_address]
    )

    post.save

    Post.collection.first
  end

  let(:second_post) do
    post = Post.new(
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraph,
      user_id: user[:id],
      author_ip_address: user[:ip_address]
    )

    post.save

    Post.collection.all.last
  end

  let(:token) do
    request = instance_double(Rack::Request)
    allow(request).to receive_message_chain(:body, :readlines, :join).and_return({ username: user[:username] }.to_json)
    response = AuthenticationsController.new(request).create

    JSON.parse(response.dig(2, 0).to_s)['access_token']
  end

  context 'when the post id are correct and rating is valid' do
    it 'returns the current average rating of that post' do
      first_rate = create_rating_with_data(data: {
        post_id: first_post[:id],
        rating: 5
      })

      second_rate = create_rating_with_data(data: {
        post_id: first_post[:id],
        rating: 3
      })

      third_rate = create_rating_with_data(data: {
        post_id: second_post[:id],
        rating: 5
      })

      expect(second_rate[0]).to eq(200)
      expect(JSON.parse(second_rate[2][0])).to eq(
        {
          'avg_rating' => 4.0
        }
      )

      expect(third_rate[0]).to eq(200)
      expect(JSON.parse(third_rate[2][0])).to eq(
        {
          'avg_rating' => 5.0
        }
      )
    end
  end

  context 'when the post id are correct and rating is out of range' do
    it 'returns error rate is out of range with 422 status' do
      rate_above_five = create_rating_with_data(data: {
        post_id: first_post[:id],
        rating: 6
      })

      rate_below_one = create_rating_with_data(data: {
        post_id: first_post[:id],
        rating: 0
      })

      expect(JSON.parse(rate_above_five[2][0])).to eq(
        {
          'errors' => {
            'rating' => [
              'must be between 1 and 5'
            ]
          }
        }
      )

      expect(JSON.parse(rate_below_one[2][0])).to eq(
        {
          'errors' => {
            'rating' => [
              'must be between 1 and 5'
            ]
          }
        }
      )
    end
  end

  context 'when the post id is not found' do
    it 'returns error rate is out of range with 422 status' do
      response = create_rating_with_data(data: {
        post_id: first_post[:id] + 1000,
        rating: 5
      })

      expect(JSON.parse(response[2][0])).to eq(
        {
          'errors' => {
            'post_id' => [
              'The post must be existed'
            ]
          }
        }
      )
    end
  end
end

def create_rating_with_data(data:)
  request = instance_double(Rack::Request)
  allow(request).to receive_message_chain(:env, :[], :split, :[]).and_return(token)
  allow(request).to receive_message_chain(:body, :readlines, :join).and_return(
    data.to_json
  )
  RatingsController.new(request).create
end
