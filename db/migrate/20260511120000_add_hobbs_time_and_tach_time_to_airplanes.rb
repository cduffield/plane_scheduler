class AddHobbsTimeAndTachTimeToAirplanes < ActiveRecord::Migration[8.1]
  def change
    add_column :airplanes, :hobbs_time, :decimal, precision: 8, scale: 1
    add_column :airplanes, :tach_time, :decimal, precision: 8, scale: 1
  end
end
