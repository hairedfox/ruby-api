class AuthenticationsController < BaseController
  require 'sequel'
  require 'dotenv/load'
  require_relative '../../lib/json_web_token.rb'
  require_relative '../models/errors/not_found.rb'

  def create
    db = select_database
    users = db[:users]
    user = users.where(username: body_params['username']).first

    raise NotFound, 'user_not_found' unless user

    access_token = JsonWebToken.encode({ username: user[:username] })
    [200, { 'Content-Type' => 'application/json' }, [{access_token: access_token}.to_json]]
  rescue NotFound => e
    [404, { 'Content-Type' => 'application/json' }, [{ error: e.message }.to_json]]
  end
end
