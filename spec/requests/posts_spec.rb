require 'rack'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/authentications_controller.rb'
require_relative '../../app/controllers/posts_controller.rb'
require_relative '../../app/models/user.rb'
require_relative '../../app/models/post.rb'
require_relative '../../app/models/rating.rb'

RSpec.describe PostsController, type: :request do
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

  describe '#index' do
    before do
      allow(request).to receive(:params).and_return({})
      allow(request).to receive_message_chain(:env, :[], :split, :[]).and_return(token)
    end

    context 'when the limit is not in the query params' do
      before do
        11.times do
          Post.create(
            title: Faker::Lorem::sentence,
            content: Faker::Lorem::paragraph,
            author_ip_address: user[:ip_address],
            user_id: user[:id]
          )
          post = Post.collection.all.last
          Rating.create(
            post_id: post[:id],
            user_id: user[:id],
            rating: 2
          )
        end
      end

      it 'returns 10 posts as default' do
        allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'GET', 'HTTP_AUTHORIZATION' => "Bearer #{token}" })
        response = PostsController.new(request).index
        expect(JSON.parse(response[2][0]).size).to eq(10)
      end
    end

    context 'when the limit is specified' do
      before do
        11.times do
          Post.create(
            title: Faker::Lorem::sentence,
            content: Faker::Lorem::paragraph,
            author_ip_address: user[:ip_address],
            user_id: user[:id]
          )
          post = Post.collection.all.last
          Rating.create(
            post_id: post[:id],
            user_id: user[:id],
            rating: 2
          )
        end
      end

      it 'returns 5 posts as the limit' do
        allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'GET', 'HTTP_AUTHORIZATION' => "Bearer #{token}" })
        allow(request).to receive(:params).and_return({ 'limit' => 5 })
        response = PostsController.new(request).index
        expect(JSON.parse(response[2][0]).size).to eq(5)
      end
    end
  end

  describe '#create' do
    before do
      allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'POST' })
      allow(request).to receive(:params).and_return({})
    end

    context 'when the title and the content are filled' do
      it 'returns the post attributes with 200 status' do
        count = Post.count

        response = create_post_with_data(data: {
          title: 'Test title',
          content: 'Test content'
        })

        expect(response[0]).to eq(200)
        expect(Post.count).to eq(count + 1)
        expect(JSON.parse(response[2][0])).to match(
          {
            'title' => 'Test title',
            'content' => 'Test content',
            'user_id' => user[:id],
            'author_ip_address' => user[:ip_address]
          }
        )
      end
    end

    context 'when the title is empty' do
      it 'returns the validation error with status 422' do
        count = Post.count
        response = create_post_with_data(data: {
          title: '',
          content: 'sample content'
        })

        expect(response[0]).to eq(422)
        expect(Post.count).to eq(count)
        expect(JSON.parse(response[2][0])).to match(
          {
            'errors' => {
              'title' => ['must be present']
            }
          }
        )
      end
    end

    context 'when the content is empty' do
      it 'returns the validation error with status 422' do
        count = Post.count

        response = create_post_with_data(data: {
          title: 'Test title',
          content: ''
        })

        expect(response[0]).to eq(422)
        expect(Post.count).to eq(count)
        expect(JSON.parse(response[2][0])).to match(
          {
            'errors' => {
              'content' => ['must be present']
            }
          }
        )
      end
    end
  end
end

def create_post_with_data(data:)
  allow(request).to receive_message_chain(:env, :[], :split, :[]).and_return(token)
  allow(request).to receive_message_chain(:body, :readlines, :join).and_return(
    data.to_json
  )
  PostsController.new(request).create
end
