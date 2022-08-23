require 'rack'
require 'rack/handler/puma'
require 'sequel'
require 'json'

require_relative('./config/application.rb')

app = -> env {
  Application.new.call(env)
}

Rack::Handler::Puma.run(app, Port: 1337, Verbose: true)
