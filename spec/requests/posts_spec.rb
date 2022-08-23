require 'rack'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/posts_controller.rb'
require_relative '../../app/models/user.rb'
require_relative '../../app/models/post.rb'

RSpec.describe PostsController, type: :request do
  let(:user) do
    user = User.new(
      username: Faker::Internet.unique.username,
      ip_address: Faker::Internet.unique.ip_v4_address
    )

    user.save

    User.find_by_username(user.username)
  end

  let(:token) do
    request = instance_double(Rack::Request)
    allow(request).to receive_message_chain(:body, :readlines, :join).and_return({ username: user[:username] }.to_json)
    response = AuthenticationsController.new(request).create

    JSON.parse(response.dig(2, 0).to_s)['access_token']
  end

  context 'when the title and the content are filled' do
    it 'returns the post attributes with 200 status' do
      count = Post.count
      request = instance_double(Rack::Request)
      allow(request).to receive_message_chain(:env, :[], :split, :[]).and_return(token)
      allow(request).to receive_message_chain(:body, :readlines, :join).and_return(
        {
          title: 'Test title',
          content: 'Test content'
        }.to_json
      )
      response = PostsController.new(request).create

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
end
