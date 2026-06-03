class AddAccountToAirplanes < ActiveRecord::Migration[8.1]
  def up
    add_reference :airplanes, :account, foreign_key: true

    default_account_id = select_value("SELECT id FROM accounts ORDER BY id ASC LIMIT 1")

    if default_account_id.present?
      execute "UPDATE airplanes SET account_id = #{connection.quote(default_account_id)} WHERE account_id IS NULL"
    elsif select_value("SELECT COUNT(*) FROM airplanes").to_i.positive?
      raise ActiveRecord::IrreversibleMigration, "Cannot backfill airplanes without at least one account"
    end

    change_column_null :airplanes, :account_id, false
  end

  def down
    remove_reference :airplanes, :account, foreign_key: true
  end
end
