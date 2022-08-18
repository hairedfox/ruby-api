require 'sequel'

db = Sequel.connect('sqlite://db/schema.db')

db.create_table :users do
  primary_key :id
  String :email
  String :password_digest
end
