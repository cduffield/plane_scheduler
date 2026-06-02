class CreateMaintenanceInspections < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_inspections do |t|
      t.references :airplane, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :tracking_type, null: false, default: 0
      t.integer :calendar_interval_value
      t.integer :calendar_interval_unit
      t.integer :hour_interval_type
      t.decimal :hour_interval_value, precision: 8, scale: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
