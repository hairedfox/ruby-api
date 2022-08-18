require 'rack'
require 'rack/handler/puma'
require 'sequel'

db = Sequel.connect('sqlite://db/schema.db')

app = -> environment {
  request = Rack::Request.new(environment)

  response = Rack::Response.new

  if request.get? && request.path == '/'
    response.write('Hello World!')
  end

  response.finish
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
