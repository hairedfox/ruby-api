require_relative '../app/controllers/base_controller.rb'
require_relative '../app/controllers/authentications_controller.rb'
require_relative '../app/controllers/posts_controller.rb'
require_relative '../app/controllers/ratings_controller.rb'

class Application
  def call(env)
    request = Rack::Request.new(env)

    handle_request(request)
  end

  private

  def handle_request(request)
    path = request.path.dup.delete_prefix('/')

    method = request.env['REQUEST_METHOD']
    controller = "#{path.split('/').first.capitalize}Controller"
    controller_klass = Object.const_get(controller)

    action = retrieve_action(method, path)

    controller_klass.new(request).public_send(action)
  end

  def retrieve_action(method, path)
    case true
    when method == 'POST' && path.match?(/^\w+\/?$/)
      'create'
    when method == 'PUT' && path.match?(/^\w+\/\d+\/?$/)
      'update'
    when method == 'GET' && path.match?(/^\w+\/?$/)
      'index'
    when method == 'GET' && path.match?(/^\w+\/\d+\/?$/)
      'show'
    else
      File.basename(path)
    end
  end
end
