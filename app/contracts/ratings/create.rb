require_relative '../../utils/global_actions.rb'
require_relative '../../models/post.rb'
require_relative '../../models/user.rb'

module Contracts
  module Ratings
    class Create < Contracts::ApplicationContract
      include GlobalActions

      params do
        required(:post_id).value(:integer)
        required(:user_id).value(:integer)
        required(:rating).value(:integer)
      end

      rule(:rating) do
        key.failure('must be between 1 and 5') if value < 1 || value > 5
      end

      rule(:user_id) do
        key.failure('must be a real user') if User.find(value).to_h.empty?
      end

      rule(:post_id) do
        key.failure('The post must be existed') if Post.find(value).to_h.empty?
      end
    end
  end
end
