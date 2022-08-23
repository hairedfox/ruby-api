require_relative('./service_object.rb')
require_relative('../../lib/json_web_token.rb')

class AuthorizationService
  include ServiceObject

  attr_reader :token

  def initialize(token)
    @token = token
  end

  def call
    payload = JsonWebToken.decode(token)

    User.find(payload[:id]) if payload
  end
end
