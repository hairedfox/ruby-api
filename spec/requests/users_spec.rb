require 'rack'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/authentications_controller.rb'
require_relative '../../app/controllers/users_controller.rb'
require_relative '../../app/models/user.rb'

RSpec.describe UsersController, type: :request do
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

    it 'returns an array of users separated by ip_address' do
      allow(request).to receive(:env).and_return({ 'REQUEST_METHOD' => 'GET', 'HTTP_AUTHORIZATION' => "Bearer #{token}" })
      response = UsersController.new(request).index
      expect(response[0]).to eq(200)
      expect(JSON.parse(response[2][0])).to eq([
        {
          'ip_address' => user[:ip_address],
          'authors' => [
            'id' => user[:id],
            'ip_address' => user[:ip_address],
            'username' => user[:username]
          ]
        }
      ])
    end
  end
end
