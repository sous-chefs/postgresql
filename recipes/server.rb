#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
::Chef::Recipe.send(:include, Opscode::Postgresql::X509Subjects)

include_recipe "postgresql::client"

# randomly generate postgres password, unless using solo - see README
if Chef::Config[:solo]
  missing_attrs = %w{
    postgres
  }.select do |attr|
    node['postgresql']['password'][attr].nil?
  end.map { |attr| "node['postgresql']['password']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!([
        "You must set #{missing_attrs.join(', ')} in chef-solo mode.",
        "For more information, see https://github.com/opscode-cookbooks/postgresql#chef-solo-note"
      ].join(' '))
  end
else
  # TODO: The "secure_password" is randomly generated plain text, so it
  # should be converted to a PostgreSQL specific "encrypted password" if
  # it should actually install a password (as opposed to disable password
  # login for user 'postgres'). However, a random password wouldn't be
  # useful if it weren't saved as clear text in Chef Server for later
  # retrieval. 
  node.set_unless['postgresql']['password']['postgres'] = secure_password
  node.save
end

# Include the right "family" recipe for installing the server
# since they do things slightly differently.
case node['platform_family']
when "rhel", "fedora", "suse"
  include_recipe "postgresql::server_redhat"
when "debian"
  include_recipe "postgresql::server_debian"
end

# The postgresql server won't start if ssl=on is specified but the
# server.key and server.crt don't exist yet. Since the template for
# the postgresql.conf file does an immediate service restart, we
# should generate a ssl key and certificate first. This would be a
# self-signed certificate suitable for encrypted SSL connections.
# A certificate signed by a certificate authority (CA) should be used
# if clients need to verify the server's identity.
if (node['postgresql']['server'].attribute?('generate_x509_certificate'))
  # Defaults in case attribute doesn't specify or is a TrueClass.
  days_to_certify = 3650
  x509_subject = "/"

  x509_spec = node['postgresql']['server']['generate_x509_certificate']
  if (x509_spec.is_a?(Chef::Node::Attribute))
    x509_subject = assemble_x509_subject(Hash[x509_spec])
    if (x509_spec.attribute?('days_to_certify'))
      days_to_certify = x509_spec['days_to_certify']
    end
  end

  bash "Create SSL Private Key and Server Certificate" do
      user "postgres"
      group "postgres"
      cwd "#{node[:postgresql][:dir]}"
      code <<-EOH
        umask 077
        # server.key, an unencrypted 2048-bit RSA private key.
        openssl genrsa 2048 \
                >server.key
        # server.crt, a self-signed X509 certificate.
        openssl req -new -x509 \
                -key server.key \
                -days "#{days_to_certify}" \
                -subj "#{x509_subject}" \
                >server.crt
      EOH
      # The server.key and server.crt are only examined during server start
      notifies :restart, 'service[postgresql]'
      not_if { File.exists?("#{node[:postgresql][:dir]}/server.crt") }
  end
end

template "#{node['postgresql']['dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, 'service[postgresql]', :immediately
end

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source "pg_hba.conf.erb"
  owner "postgres"
  group "postgres"
  mode 00600
  notifies :reload, 'service[postgresql]', :immediately
end

# NOTE: Consider two facts before modifying "assign-postgres-password":
# (1) Passing the "ALTER ROLE ..." through the psql command only works
#     if passwordless authorization was configured for local connections.
#     For example, if pg_hba.conf has a "local all postgres ident" rule.
# (2) It is probably fruitless to optimize this with a not_if to avoid
#     setting the same password. This chef recipe doesn't have access to
#     the plain text password, and testing the encrypted (md5 digest)
#     version is not straight-forward.
bash "assign-postgres-password" do
  user 'postgres'
  code <<-EOH
    echo "ALTER ROLE postgres ENCRYPTED PASSWORD '#{node['postgresql']['password']['postgres']}';" | psql
  EOH
  action :run
end
