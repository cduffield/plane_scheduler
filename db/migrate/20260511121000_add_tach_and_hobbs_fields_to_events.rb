class AddTachAndHobbsFieldsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :tach_start, :decimal, precision: 8, scale: 1
    add_column :events, :tach_end, :decimal, precision: 8, scale: 1
    add_column :events, :hobbs_start, :decimal, precision: 8, scale: 1
    add_column :events, :hobbs_end, :decimal, precision: 8, scale: 1
  end
end
