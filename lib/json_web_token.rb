class JsonWebToken
  require 'jwt'

  class << self
    require 'dotenv/load'
    Dotenv.load

    def encode(payload, exp = Time.now + 24 * 60 * 60)
      payload[:exp] = exp.to_i
      JWT.encode(payload, ENV['JWT_SECRET'])
    end

    def decode(token)
      JWT.decode(token, ENV['JWT_SECRET'])[0]
    rescue
      nil
    end
  end
 end
