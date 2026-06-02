class EventPayment < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :pay_charge, class_name: "Pay::Charge", optional: true

  enum :status, { pending: 0, paid: 1, failed: 2, cancelled: 3 }

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :event_id, uniqueness: { scope: :user_id }
end
