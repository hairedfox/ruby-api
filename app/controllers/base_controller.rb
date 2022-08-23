class BaseController
  attr_reader :request, :body_params

  def initialize(request)
    @request = request
    @body_params = JSON.parse(request.body.readlines.join)
  end
end
