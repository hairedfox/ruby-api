require 'rack'
require 'rack/handler/puma'
require 'sequel'
require 'json'

db = Sequel.connect('sqlite://db/schema.db')

def handle_requests(request)
  case [request.env['REQUEST_METHOD'], request.path]
  when ['POST', '/sessions']
    # TODO: Handle user login here
  else
    [200, {'Content-Type' => 'application/json'}, [{}.to_json]]
  end
end

app = -> environment {
  request = Rack::Request.new(environment)

  handle_requests(request)
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
