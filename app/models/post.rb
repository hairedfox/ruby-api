require 'dry-struct'
require_relative '../utils/types'
require_relative '../utils/global_actions'

class Post < Dry::Struct
  attribute :title, Types::String
  attribute :content, Types::String
  attribute :user_id, Types::Coercible::Integer
  attribute :author_ip_address, Types::String

  class << self
    include GlobalActions

    def count
      collection.count
    end

    def collection
      @collection ||= db[:posts]
    end

    def db
      @db ||= select_database
    end
  end

  def save
    self.class.collection.insert(title:, content:, user_id:, author_ip_address:)

    true
  end

  def serialize
    {
      title:,
      content:,
      user_id:,
      author_ip_address:
    }.to_json
  end
end
