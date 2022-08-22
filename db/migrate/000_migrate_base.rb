class MigrateBase
  require 'sequel'
  require 'dotenv/load'

  Dotenv.load

  def self.db
    @db ||= Sequel.connect(ENV['DB_URL'])
  end
end
