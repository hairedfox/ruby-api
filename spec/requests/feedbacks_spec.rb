require 'rack'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/authentications_controller.rb'
require_relative '../../app/controllers/feedbacks_controller.rb'
require_relative '../../app/models/user.rb'
require_relative '../../app/models/post.rb'
require_relative '../../app/models/feedback.rb'

RSpec.describe FeedbacksController, type: :request do
  let(:request) { instance_double(Rack::Request) }
  let(:user) do
    user = User.new(
      username: Faker::Internet.unique.username,
      ip_address: Faker::Internet.unique.ip_v4_address
    )

    user.save

    User.find_by_username(user.username)
  end

  let(:token) do
    allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'POST', 'HTTP_AUTHORIZATION' => '' })
    allow(request).to receive_message_chain(:body, :readlines, :join).and_return({ username: user[:username] }.to_json)
    response = AuthenticationsController.new(request).create
    JSON.parse(response.dig(2, 0).to_s)['access_token']
  end

  describe '#create' do
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

    let(:second_user) do
      user = User.new(
        username: Faker::Internet.unique.username,
        ip_address: Faker::Internet.unique.ip_v4_address
      )

      user.save

      User.find_by_username(user.username)
    end

    before do
      allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'POST' })
      allow(request).to receive(:params).and_return({})
    end

    context 'when information is correct and feedback the first time' do
      it 'returns list feedbacks of the owner' do
        create_feedback_with_data(data: {
          target_id: first_post[:id],
          target_type: 'Post',
          comment: 'Great stuff'
        })

        create_feedback_with_data(data: {
          target_id: second_post[:id],
          target_type: 'Post',
          comment: 'Great stuff 2'
        })

        last_response = create_feedback_with_data(data: {
          target_id: second_user[:id],
          target_type: 'User',
          comment: 'Great stuff 3'
        })

        response_data = JSON.parse(last_response[2][0])

        expect(last_response[0]).to eq(200)
        expect(response_data.size).to eq(3)
        expect(response_data[0]).to match({
          'id' => anything,
          'target_id' => first_post[:id],
          'comment' => 'Great stuff',
          'target_type' => 'Post',
          'user_id' => user[:id]
        })
        expect(response_data[1]).to match({
          'id' => anything,
          'target_id' => second_post[:id],
          'comment' => 'Great stuff 2',
          'target_type' => 'Post',
          'user_id' => user[:id]
        })
        expect(response_data[2]).to match({
          'id' => anything,
          'target_id' => second_user[:id],
          'comment' => 'Great stuff 3',
          'target_type' => 'User',
          'user_id' => user[:id]
        })
      end
    end

    context 'when feedback for the second time on user' do
      it 'return an error with 422 status code' do
        create_feedback_with_data(data: {
          target_id: second_user[:id],
          target_type: 'User',
          comment: 'Great stuff'
        })

        last_response = create_feedback_with_data(data: {
          target_id: second_user[:id],
          target_type: 'User',
          comment: 'Great stuff'
        })

        error_obj = JSON.parse(last_response[2][0])

        expect(last_response[0]).to eq(422)
        expect(error_obj).to match({
          'errors' => {
            'target_id' => [
              'You already feedback this user'
            ]
          }
        })
      end
    end

    context 'when feedback for the second time on post' do
      it 'return an error with 422 status code' do
        create_feedback_with_data(data: {
          target_id: first_post[:id],
          target_type: 'Post',
          comment: 'Great stuff'
        })

        last_response = create_feedback_with_data(data: {
          target_id: first_post[:id],
          target_type: 'Post',
          comment: 'Great stuff 2'
        })

        error_obj = JSON.parse(last_response[2][0])

        expect(last_response[0]).to eq(422)
        expect(error_obj).to match({
          'errors' => {
            'target_id' => [
              'You already feedback this post'
            ]
          }
        })
      end
    end
  end
end

def create_feedback_with_data(data: {})
  allow(request).to receive_message_chain(:env, :[], :split, :[]).and_return(token)
  allow(request).to receive_message_chain(:body, :readlines, :join).and_return(
    data.to_json
  )
  FeedbacksController.new(request).create
end
