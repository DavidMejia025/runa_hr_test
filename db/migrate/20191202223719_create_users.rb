class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.integer :id_number
      t.integer :role
      t.integer :department
      t.string :position
      t.string :password_digest

      t.timestamps
    end
  end
end
