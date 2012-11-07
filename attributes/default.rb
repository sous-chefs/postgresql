#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008-2009, Opscode, Inc.
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

case platform
when "debian"

  case
  when platform_version.to_f <= 5.0
    default['postgresql']['version'] = "8.3"
  when platform_version.to_f == 6.0
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end

  set['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

when "ubuntu"

  case
  when platform_version.to_f <= 9.04
    default['postgresql']['version'] = "8.3"
  when platform_version.to_f <= 11.04
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end

  set['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

when "fedora"

  if platform_version.to_f <= 12
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "8.4"
  end

  set['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

when "amazon"

  default['postgresql']['version'] = "8.4"
  set['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

when "redhat","centos","scientific"

  default['postgresql']['version'] = "8.4"
  set['postgresql']['dir'] = "/var/lib/pgsql/data"

  if node['platform_version'].to_f >= 6.0
    default['postgresql']['client']['packages'] = %w{postgresql-devel}
    default['postgresql']['server']['packages'] = %w{postgresql-server}
  else
    default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
    default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  end

when "suse"

  case
  when platform_version.to_f <= 11.1
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "9.0"
  end

  set['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

else
  default['postgresql']['version'] = "8.4"
  set['postgresql']['dir']         = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['client']['packages'] = ["postgresql"]
  default['postgresql']['server']['packages'] = ["postgresql"]
end

default[:postgresql][:listen_addresses] = "localhost"

if(node.platform_family == 'debian')
  default[:postgresql][:config][:data_directory] = "/var/lib/postgresql/#{node.postgresql.version}/main"
  default[:postgresql][:config][:hba_file] = "/etc/postgresql/#{node.postgresql.version}/main/pg_hba.conf"
  default[:postgresql][:config][:ident_file] = "/etc/postgresql/#{node.postgresql.version}/main/pg_ident.conf"
  default[:postgresql][:config][:external_pid_file] = "/var/run/postgresql/#{node[:postgresql][:version]}-main.pid"
  default[:postgresql][:config][:listen_addresses] = node[:postgresql][:listen_addresses]
  default[:postgresql][:config][:port] = 5432
  default[:postgresql][:config][:max_connections] = 100
  default[:postgresql][:config][:unix_socket_directory] = '/var/run/postgresql'
  default[:postgresql][:config][:ssl] = node[:postgresql][:ssl]
  default[:postgresql][:config][:shared_buffers] = '24MB'
  default[:postgresql][:config][:max_fsm_pages] = 153600 if node[:postgresql][:version].to_f < 8.4
  default[:postgresql][:config][:log_line_prefix] = '%t '
  default[:postgresql][:config][:datestyle] = 'iso, mdy'
  default[:postgresql][:config][:default_text_search_config] = 'pg_catalog.english'
else
  default[:postgresql][:config][:listen_addresses] = node[:postgresql][:listen_addresses]
  default[:postgresql][:config][:max_connections] = node[:postgresql][:max_connections]
  default[:postgresql][:config][:shared_buffers] = '32MB'
  default[:postgresql][:config][:logging_collector] = true
  default[:postgresql][:config][:log_directory] = 'pg_log'
  default[:postgresql][:config][:log_filename] = 'postgresql-%a.log'
  default[:postgresql][:config][:log_truncate_on_rotation] = true
  default[:postgresql][:config][:log_rotation_age] = '1d'
  default[:postgresql][:config][:log_rotation_size] = 0
  default[:postgresql][:config][:datestyle] = 'iso, mdy'
  default[:postgresql][:config][:lc_messages] = 'en_US.UTF-8'
  default[:postgresql][:config][:lc_monetary] = 'en_US.UTF-8'
  default[:postgresql][:config][:lc_numeric] = 'en_US.UTF-8'
  default[:postgresql][:config][:lc_time] = 'en_US.UTF-8'
  default[:postgresql][:config][:default_text_search_config] = 'pg_catalog.english'
end
default[:postgresql][:pg_hba] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]
