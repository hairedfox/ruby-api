require 'rack'
require 'json'
require 'faker'
require_relative '../../app/controllers/base_controller.rb'
require_relative '../../app/controllers/authentications_controller.rb'
require_relative '../../app/models/user.rb'

RSpec.describe AuthenticationsController, type: :controller do
  let(:user) do
    user = User.new(
      username: Faker::Internet.unique.username,
      ip_address: Faker::Internet.unique.ip_v4_address
    )

    user.save

    user
  end

  context 'when the username is correct' do
    it 'returns the access_token' do
      request = instance_double(Rack::Request)
      allow(request).to receive_message_chain(:body, :readlines, :join).and_return({ 'username' => user.username }.to_json)
      response = AuthenticationsController.new(request).create

      expect(response[0]).to eq(200)
      expect(response[1]).to eq({ 'Content-Type' => 'application/json' })
      expect(JSON.parse(response[2][0])).to match({ 'access_token' => anything })
    end
  end

  context 'when the username is wrong' do
    it 'returns 404' do
      request = instance_double(Rack::Request)
      allow(request).to receive_message_chain(:body, :readlines, :join).and_return({ 'username' => 'sample name' }.to_json)
      response = AuthenticationsController.new(request).create

      expect(response[0]).to eq(404)
      expect(response[1]).to eq({ 'Content-Type' => 'application/json' })
      expect(JSON.parse(response[2][0])).to match({ 'error' => 'user_not_found' })
    end
  end
end
