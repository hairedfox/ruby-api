require 'dry-struct'
require_relative '../utils/global_actions.rb'
require_relative '../utils/types.rb'

class User < Dry::Struct
  attribute :username, Types::String
  attribute :ip_address, Types::String

  class << self
    include GlobalActions

    def group_by_ips
      collection.all.group_by { |user| user[:ip_address] }
                .reduce([]) { |arr, (k, v)| arr << { ip_address: k, authors: v }; arr }
    end

    def where(**args)
      collection.where(**args)
    end

    def find(id)
      collection.where(id:).first
    end

    def find_by_username(username)
      collection.where(username:).first
    end

    def collection
      @collection ||= db[:users]
    end

    def db
      @db ||= select_database
    end
  end

  def save
    self.class.collection.insert(username:, ip_address:)

    true
  end
end
