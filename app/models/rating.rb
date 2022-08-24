require 'dry-struct'
require 'json'
require_relative '../utils/types.rb'
require_relative '../utils/global_actions.rb'
require_relative '../contracts/ratings/create.rb'

class Rating < Dry::Struct
  attribute :post_id, Types::Coercible::Integer
  attribute :user_id, Types::Coercible::Integer
  attribute :rating, Types::Coercible::Integer

  class << self
    include GlobalActions

    def post_ids_by_avg_rating(limit: 10)
      limit = limit.is_a?(Integer) ? limit : 10

      post_ids = db.fetch("SELECT AVG(rating) AS avg_rating, post_id FROM ratings GROUP BY post_id ORDER BY avg_rating DESC").limit(limit)
        .map { |el| el[:post_id] }
    end

    def average(post_id:)
      collection.where(post_id:).avg(:rating).to_f.round(2)
    end

    def collection
      @collection ||= db[:ratings]
    end

    def db
      @db ||= select_database
    end

    def create(**args)
      result = Contracts::Ratings::Create.call(
        post_id: args[:post_id],
        user_id: args[:user_id],
        rating: args[:rating]
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
end
