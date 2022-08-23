class AuthenticationsController < BaseController
  require_relative '../../lib/json_web_token.rb'
  require_relative '../models/errors/not_found.rb'
  require_relative '../models/user.rb'

  def create
    user = User.find_by_username(body_params['username'])

    raise NotFound, 'user_not_found' unless user

    access_token = JsonWebToken.encode({ username: user[:username] })

    response_with(code: 200, data: [{ access_token: access_token }.to_json])
  rescue NotFound => e
    response_with(code: 404, data: [{ error: e.message }.to_json])
  end
end
