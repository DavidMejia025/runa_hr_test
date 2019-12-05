class ChangeLogsCheckinAndCHeckoutColumns < ActiveRecord::Migration[5.2]
  def up
    change_column :logs, :check_in,  :datetime
    change_column :logs, :check_out, :datetime
  end

  def down
    change_column :logs, :check_in,  :date
    change_column :logs, :check_out, :daete
  end
end
