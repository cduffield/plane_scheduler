class Airplane < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :maintenance_inspections, dependent: :destroy
end
