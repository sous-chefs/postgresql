#
# Cookbook Name:: postgresql
# Recipe:: setup_users
#

# setup users

node["postgresql"]["users"].each do |user|
  postgresql_user user["username"] do
    superuser user["superuser"]
    createdb  user["createdb"]
    login     user["login"]
    password  user["password"]
    encrypted_password user["encrypted_password"]
    action Array(user["action"] || "create").map(&:to_sym)
  end
end
