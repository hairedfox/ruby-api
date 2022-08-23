class AuthenticationsController < BaseController
  require 'json'
  require 'sequel'
  require 'dotenv/load'
  require_relative '../../lib/json_web_token.rb'

  def create
    db = Sequel.connect(ENV['DB_URL'])
    users = db[:users]
    user = users.where(username: body_params['username']).first

    access_token = JsonWebToken.encode({ username: user[:username] })

    [200, { 'Content-Type' => 'application/json' }, [{access_token: access_token}.to_json]]
  end
end
