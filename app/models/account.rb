class Account < ApplicationRecord
  include Billing, Domains, Transfer, Types

  has_many :airplanes, dependent: :destroy
  has_many :events, through: :airplanes
end
