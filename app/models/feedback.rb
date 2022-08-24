require 'dry-struct'
require 'json'
require_relative '../utils/types'
require_relative '../utils/global_actions'
require_relative '../contracts/feedbacks/create.rb'

class Feedback < Dry::Struct
  attribute :comment, Types::String
  attribute :user_id, Types::Coercible::Integer
  attribute :target_id, Types::Coercible::Integer
  attribute :target_type, Types::String

  class << self
    include GlobalActions

    def by_user_id(user_id)
      where(user_id:)
    end

    def where(**args)
      collection.where(**args)
    end

    def create(**args)
      result = Contracts::Feedbacks::Create.call(
        target_id: args[:target_id],
        target_type: args[:target_type],
        user_id: args[:user_id],
        comment: args[:comment]
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

    def collection
      @collection ||= db[:feedbacks]
    end

    def db
      @db ||= select_database
    end
  end
end
