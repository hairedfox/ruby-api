require_relative '../services/authorization_service.rb'
require_relative '../utils/global_actions.rb'
require_relative '../models/errors/permission_denied.rb'

class BaseController
  include GlobalActions

  attr_reader :request, :body_params, :query_params

  def initialize(request)
    @request = request
    @body_params = get? ? {} : JSON.parse(request.body.readlines.join.to_s)
    @query_params = request.params
  end

  def current_user
    @current_user ||= begin
      token = request.env['HTTP_AUTHORIZATION'].split(' ')[1]

      AuthorizationService.call(token)
    rescue
      nil
    end
  end

  private

  def get?
    request.env['REQUEST_METHOD'] == 'GET'
  end

  def authorize!
    raise PermissionDenied, 'permission_denied' unless current_user
  rescue PermissionDenied => e
    response_with(code: 403, data: [{ error: e.message }.to_json])
  end

  def response_with(code:, headers: { 'Content-Type' => 'application/json' }, data: [])
    [code, headers, data]
  end
end
