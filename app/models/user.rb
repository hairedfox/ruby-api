require 'dry-struct'
require_relative '../utils/global_actions.rb'
require_relative '../utils/types.rb'

class User < Dry::Struct
  include GlobalActions

  attribute :username, Types::String
  attribute :ip_address, Types::String

  def save
    db = select_database
    users = db[:users]

    users.insert(username:, ip_address:)

    true
  end
end
