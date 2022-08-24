require 'dry-struct'
require 'json'
require_relative '../utils/types'
require_relative '../utils/global_actions'
require_relative '../contracts/posts/create.rb'

class Post < Dry::Struct
  attribute :title, Types::String
  attribute :content, Types::String
  attribute :user_id, Types::Coercible::Integer
  attribute :author_ip_address, Types::String
  attribute :errors, Types::String.default({}.to_json)

  class << self
    include GlobalActions

    def where(**args)
      collection.where(**args)
    end

    def find(id)
      collection.where(id:).first
    end

    def count
      collection.count
    end

    def collection
      @collection ||= db[:posts]
    end

    def db
      @db ||= select_database
    end

    def create(**args)
      result = Contracts::Posts::Create.call(
        title: args[:title],
        content: args[:content],
        user_id: args[:user_id],
        author_ip_address: args[:author_ip_address]
      )

      if result.success?
        collection.insert(result.to_h)
        {
          success: true,
          data: result.to_h
        }
      else
        {
          success: false,
          data: [],
          errors: result.errors.to_h
        }
      end
    end
  end

  def save
    result = Contracts::Posts::Create.call(title:, content:, user_id:, author_ip_address:)

    if result.success?
      self.class.collection.insert(result.to_h)
      true
    else
      self.errors = result.errors.to_h.to_json
      false
    end
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
