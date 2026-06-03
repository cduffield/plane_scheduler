class User < ApplicationRecord
  pay_customer

  include Accounts, Agreements, Authenticatable, Mentions, Notifiable, Profile, Searchable, Theme

  has_many :event_payments, dependent: :destroy

  def system_theme? = false

  def dark_theme? = false

  def light_theme? = true
end
