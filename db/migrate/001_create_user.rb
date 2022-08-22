require_relative('./000_migrate_base.rb')

class CreateUser < MigrateBase
  def self.call
    db.create_table :users do
      primary_key :id
      String :username, size: 100, unique: true
      String :ip_address, size: 15
    end
  end
end

CreateUser.call
