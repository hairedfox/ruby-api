require_relative('./base_controller.rb')
require_relative('../models/post.rb')

class PostsController < BaseController
  def create
    error = authorize!
    return error if error

    post = Post.new(
      title: body_params['title'],
      content: body_params['content'],
      user_id: current_user[:id],
      author_ip_address: current_user[:ip_address]
    )

    post.save

    response_with(code: 200, data: [post.serialize])
  end
end
