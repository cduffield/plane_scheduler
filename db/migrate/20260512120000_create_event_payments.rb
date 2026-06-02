class CreateEventPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :event_payments do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :pay_charge, foreign_key: {to_table: :pay_charges}
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "usd"
      t.integer :status, null: false, default: 0
      t.string :stripe_checkout_session_id
      t.datetime :paid_at

      t.timestamps
    end

    add_index :event_payments, [:event_id, :user_id], unique: true
  end
end
