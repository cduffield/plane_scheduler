class User < ApplicationRecord
  pay_customer

  include Accounts, Agreements, Authenticatable, Mentions, Notifiable, Profile, Searchable, Theme

  has_many :event_payments, dependent: :destroy
end
