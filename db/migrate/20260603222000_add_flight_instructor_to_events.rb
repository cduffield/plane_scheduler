class AddFlightInstructorToEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :events, :flight_instructor, foreign_key: {to_table: :users}
  end
end
