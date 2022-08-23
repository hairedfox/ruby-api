require 'dry/validation'

module Contracts
  class ApplicationContract < Dry::Validation::Contract
    def self.call(args = {}, repo = {}, &block)
      new.call(args, repo, &block)
    end
  end
end
