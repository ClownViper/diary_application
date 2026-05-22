class AddSleepHoursAndTemperatureToHealthLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :health_logs, :sleep_hours,  :decimal, precision: 4, scale: 1
    add_column :health_logs, :temperature, :decimal, precision: 4, scale: 1
  end
end
