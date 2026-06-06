json.cache! [account] do
  json.extract! account, :name, :personal, :created_at, :updated_at
  json.account_users do
    json.array! account.account_users.includes(:user) do |account_user|
      json.name account_user.user.name
      json.roles account_user.active_roles
    end
  end
end
