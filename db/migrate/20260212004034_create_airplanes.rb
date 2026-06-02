class CreateAirplanes < ActiveRecord::Migration[8.1]
  def change
    create_table :airplanes do |t|
      t.string :n_number

      t.timestamps
    end
  end
end
