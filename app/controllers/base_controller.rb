class BaseController
  attr_reader :request, :body_params

  require_relative '../utils/global_actions.rb'

  include GlobalActions

  def initialize(request)
    @request = request
    @body_params = JSON.parse(request.body.readlines.join)
  end
end
