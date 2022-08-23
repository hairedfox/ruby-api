require 'rack'
require 'rack/handler/puma'
require 'sequel'
require 'json'
require 'pry'

require_relative './app/controllers/base_controller.rb'
Dir[File.join(__dir__, 'app', 'controllers', '**/*.rb')].each { |file| require file }

db = Sequel.connect(ENV['DB_URL'])

def handle_requests(request)
  path = request.path.dup.delete_prefix('/')

  method = request.env['REQUEST_METHOD']
  controller = "#{path.split('/').first.capitalize}Controller"
  controller_klass = Object.const_get(controller)

  action = retrieve_action(method, path)

  controller_klass.new(request).public_send(action)
end

def retrieve_action(method, path)
  case true
  when method == 'POST' && path.match?(/^\w+\/$/)
    'create'
  when method == 'PUT' && path.match?(/^\w+\/\d+\/$/)
    'update'
  when method == 'GET' && path.match?(/^\w+\/$/)
    'index'
  when method == 'GET' && path.match?(/^\w+\/\d+\/$/)
    'show'
  else
    File.basename(path)
  end
end

app = -> environment {
  request = Rack::Request.new(environment)

  handle_requests(request)
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
