#
# Cookbook Name:: postgresql
# Recipe:: setup_databases
#

databases = node["postgresql"]["databases"]

# setup databases
databases.each do |db|
  db_action = (db["action"] || "create").to_sym
  db_extensions = Array(db["extensions"])
  db_languages  = Array(db["languages"])

  postgresql_database db["name"] do
    owner db["owner"]
    encoding db["encoding"]
    template db["template"]
    locale db["locale"]
    action db_action
  end

  # check for extensions/languages to install from `databases` attribute key
  next unless db_action == :create

  db_extensions.each do |extension|
    postgresql_extension extension do
      database db["name"]
    end
  end

  db_languages.each do |language|
    postgresql_language language do
      database db["name"]
    end
  end
end
