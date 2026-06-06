class Airplane < ApplicationRecord
  belongs_to :account

  has_many :events, dependent: :destroy
  has_many :maintenance_inspections, dependent: :destroy
  has_one :airplane_solo_requirement, dependent: :destroy
  has_many :airplane_user_qualifications, dependent: :destroy

  accepts_nested_attributes_for :airplane_solo_requirement, update_only: true
end
