class AddTotalCostToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :total_cost, :decimal, precision: 10, scale: 2
  end
end
