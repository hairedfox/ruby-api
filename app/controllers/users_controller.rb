require_relative './base_controller.rb'
require_relative '../models/user.rb'

class UsersController < BaseController
  def index
    data = User.group_by_ips

    response_with(code: 200, data: [data.to_json])
  end
end
