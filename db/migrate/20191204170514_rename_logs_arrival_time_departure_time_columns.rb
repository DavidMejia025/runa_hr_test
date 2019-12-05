class RenameLogsArrivalTimeDepartureTimeColumns < ActiveRecord::Migration[5.2]
  def up
  	rename_column :logs, :arrival_time,   :check_in
  	rename_column :logs, :departure_time, :check_out
  end

  def down
    rename_column :logs, :check_in, :arrival_time
    rename_column :logs, :check_ot, :departure_time
  end
end
