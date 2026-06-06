class AddPilotQualificationsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pilot_certificates, :string, array: true, default: [], null: false
    add_column :users, :aircraft_categories, :string, array: true, default: [], null: false
    add_column :users, :aircraft_classes, :string, array: true, default: [], null: false
  end
end
