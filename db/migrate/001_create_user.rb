require 'sequel'

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :username, size: 100, unique: true
      String :ip_address
    end
  end

  down do
    drop_table(:users)
  end
end
