class AddFlightHourTotalsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :total_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :pic_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :sic_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :cross_country_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :instrument_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :night_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :simulator_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :dual_received_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
    add_column :users, :solo_time, :decimal, precision: 10, scale: 1, default: 0.0, null: false
  end
end
