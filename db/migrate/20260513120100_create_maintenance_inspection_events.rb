class CreateMaintenanceInspectionEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_inspection_events do |t|
      t.references :maintenance_inspection, null: false, foreign_key: true
      t.datetime :performed_at, null: false
      t.decimal :hobbs_time, precision: 8, scale: 1
      t.decimal :tach_time, precision: 8, scale: 1
      t.text :notes

      t.timestamps
    end
  end
end
