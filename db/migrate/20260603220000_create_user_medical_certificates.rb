class CreateUserMedicalCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :user_medical_certificates do |t|
      t.references :user, null: false, foreign_key: true, index: {unique: true}
      t.string :medical_class, null: false
      t.string :certificate_number
      t.date :issued_on
      t.date :expires_on

      t.timestamps
    end
  end
end
