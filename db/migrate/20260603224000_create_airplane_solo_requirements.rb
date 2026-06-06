class CreateAirplaneSoloRequirements < ActiveRecord::Migration[8.1]
  def change
    create_table :airplane_solo_requirements do |t|
      t.references :airplane, null: false, foreign_key: true, index: { unique: true }
      t.boolean :active, null: false, default: false
      t.boolean :requires_checkout, null: false, default: false
      t.string :required_certificate_type
      t.string :required_rating_type
      t.integer :recent_rental_days

      t.timestamps
    end
  end
end
