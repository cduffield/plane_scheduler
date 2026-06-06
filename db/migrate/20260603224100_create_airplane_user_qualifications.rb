class CreateAirplaneUserQualifications < ActiveRecord::Migration[8.1]
  def change
    create_table :airplane_user_qualifications do |t|
      t.references :airplane, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :checkout_event, foreign_key: {to_table: :events}
      t.references :approved_by, foreign_key: {to_table: :users}
      t.date :checkout_completed_at
      t.date :expires_on
      t.text :notes

      t.timestamps
    end

    add_index :airplane_user_qualifications, [:airplane_id, :user_id], unique: true
  end
end
