require 'sequel'

Sequel.migration do
  up do
    create_table(:posts) do
      primary_key :id
      String :title, size: 255
      String :content
      String :author_ip_address
    end

    alter_table(:posts) { add_foreign_key :user_id, :users }
  end

  down do
    drop_table(:posts)
  end
end
