require_relative('./base_controller.rb')
require_relative('../models/post.rb')
require 'json'

class PostsController < BaseController
  def create
    error = authorize!
    return error if error

    result = Post.create(
      title: body_params['title'],
      content: body_params['content'],
      user_id: current_user[:id],
      author_ip_address: current_user[:ip_address]
    )

    return response_with(code: 200, data: [result[:data].to_json]) if result[:success]

    response_with(code: 422, data: [{ errors: result[:errors] }.to_json])
  end
end
