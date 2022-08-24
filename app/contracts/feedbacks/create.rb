require_relative '../application_contract.rb'
require_relative '../../models/user.rb'
require_relative '../../models/feedback.rb'


module Contracts
  module Feedbacks
    class Create < Contracts::ApplicationContract
      params do
        required(:target_type).value(:string)
        required(:target_id).value(:integer)
        required(:comment).value(:string)
        required(:user_id).value(:integer)
      end

      rule(:target_id) do
        if values[:target_type] == 'Post'
          unless Feedback.where(target_id: value, user_id: values[:user_id], target_type: 'Post').first.to_h.empty?
            key.failure('You already feedback this post')
          end
        elsif values[:target_type] == 'User'
          unless Feedback.where(target_id: value, user_id: values[:user_id], target_type: 'User').first.to_h.empty?
            key.failure('You already feedback this user')
          end
        end
      end

      rule(:target_type) do
        unless %w[Post User].include?(value)
          key.failure('Target type not supported yet.')
        end
      end

      rule(:user_id) do
        if User.find(value).to_h.empty?
          key.failure('User must be present')
        end
      end
    end
  end
end
