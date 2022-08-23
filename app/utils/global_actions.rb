module GlobalActions
  require 'sequel'
  require 'dotenv/load'
  require_relative('../models/errors/not_implemented.rb')
  Dotenv.load

  def select_database
    if ENV['RUBY_ENV'] == 'test'
      db = Sequel.connect(ENV['TEST_DB_URL'])
    elsif ENV['RUBY_ENV'] == 'development'
      db = Sequel.connect(ENV['DB_URL'])
    else
      raise NotImplemented, 'This environment is not supported yet'
    end
  end
end
