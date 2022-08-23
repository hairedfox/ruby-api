class JsonWebToken
  require 'jwt'

  class << self
    def encode(payload, exp = Time.now + 24 * 60 * 60)
      payload[:exp] = exp.to_i
      JWT.encode(payload, ENV['JWT_SECRET'])
    end

    def decode(token)
      body = JWT.decode(token, ENV['JWT_SECRET'])[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
 end
