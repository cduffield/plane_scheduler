class Account < ApplicationRecord
  pay_merchant

  include Billing, Domains, Transfer, Types

  has_many :airplanes, dependent: :destroy
  has_many :events, through: :airplanes
end
