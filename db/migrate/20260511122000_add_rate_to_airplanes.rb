class AddRateToAirplanes < ActiveRecord::Migration[8.1]
  def change
    add_column :airplanes, :rate, :decimal, precision: 10, scale: 2
  end
end
