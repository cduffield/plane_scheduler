class AccountUser < ApplicationRecord
  # Do NOT use reserved words like `user` or `account` for role names.
  ROLES = [:admin, :flight_instructor]

  include Ownership, Roles, UpdatesSubscriptionQuantity
end
