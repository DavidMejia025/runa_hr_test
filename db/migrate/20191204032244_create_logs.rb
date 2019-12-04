class CreateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :logs do |t|
      t.integer :user_id
      t.date :arrival_time
      t.date :departure_time

      t.timestamps
    end
  end
end
