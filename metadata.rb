name              "postgresql"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "3.4.8"
recipe            "postgresql", "Includes postgresql::client"
recipe            "postgresql::ruby", "Installs pg gem for Ruby bindings"
recipe            "postgresql::client", "Installs postgresql client package(s)"
recipe            "postgresql::server_streaming_master", "Installs a postgresql streaming (and log shipping) master"
recipe            "postgresql::server_streaming_slave", "Install s postgresql streaming slave (and hot_standby)"
recipe            "postgresql::server", "Installs postgresql server packages, templates"
recipe            "postgresql::server_redhat", "Installs postgresql server packages, redhat family style"
recipe            "postgresql::server_debian", "Installs postgresql server packages, debian family style"
recipe            "postgresql::wal-e", "Installs wal-e S3 backup process for postgres"

%w{ubuntu debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, ">= 6.0"
end

depends "apt"
depends "build-essential"
depends "logrotate"
depends "openssl"
depends "python"
