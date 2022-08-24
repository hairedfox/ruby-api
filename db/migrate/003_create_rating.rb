require 'sequel'

Sequel.migration do
  up do
    create_table(:ratings) do
      primary_key :id
      Integer :rating
    end

    alter_table(:ratings) { add_foreign_key :user_id, :users }
    alter_table(:ratings) { add_foreign_key :post_id, :posts }
  end

  down do
    drop_table(:ratings)
  end
end
