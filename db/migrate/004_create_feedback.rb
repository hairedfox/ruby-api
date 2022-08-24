require 'sequel'

Sequel.migration do
  up do
    create_table(:feedbacks) do
      primary_key :id
      String :comment
      Integer :target_id
      String :target_type
    end

    alter_table(:feedbacks) { add_foreign_key :user_id, :users }
    alter_table(:feedbacks) { add_index %i[target_id target_type] }
  end

  down do
    drop_table(:feedbacks)
  end
end
