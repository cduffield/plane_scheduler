class CreateUserPilotCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :user_pilot_certificates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :certificate_type, null: false
      t.string :category, null: false
      t.string :aircraft_class, null: false
      t.string :certificate_number
      t.date :issued_on

      t.timestamps
    end
  end
end
