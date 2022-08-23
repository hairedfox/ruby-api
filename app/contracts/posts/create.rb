require_relative '../application_contract.rb'

module Contracts
  module Posts
    class Create < Contracts::ApplicationContract
      params do
        required(:title).value(:string)
        required(:content).value(:string)
        required(:author_ip_address).value(:string)
        required(:user_id).value(:integer)
      end

      rule(:content) do
        key.failure('must be present') if value.size == 0
      end
    end
  end
end
