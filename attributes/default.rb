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

case node['platform']
when "debian"

  case
  when node['platform_version'].to_f <= 5.0
    default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f == 6.0
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end

  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when node['platform_version'].to_f <= 5.0
    default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    default['postgresql']['server']['service_name'] = "postgresql"
  end

  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

when "ubuntu"

  case
  when node['platform_version'].to_f <= 9.04
    default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f <= 11.04
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end

  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when node['platform_version'].to_f <= 10.04
    default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    default['postgresql']['server']['service_name'] = "postgresql"
  end

  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

when "fedora"

  if node['platform_version'].to_f <= 12
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "8.4"
  end

  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}
  default['postgresql']['server']['service_name'] = "postgresql"

when "amazon"

  default['postgresql']['version'] = "8.4"
  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}
  default['postgresql']['server']['service_name'] = "postgresql"

when "redhat", "centos", "scientific", "oracle"

  default['postgresql']['version'] = "8.4"
  default['postgresql']['dir'] = "/var/lib/pgsql/data"

  if node['platform_version'].to_f >= 6.0
    default['postgresql']['client']['packages'] = %w{postgresql-devel}
    default['postgresql']['server']['packages'] = %w{postgresql-server}
  else
    default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
    default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  end
  default['postgresql']['server']['service_name'] = "postgresql"

when "suse"

  if node['platform_version'].to_f <= 11.1
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "9.0"
  end

  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}
  default['postgresql']['server']['service_name'] = "postgresql"

else
  default['postgresql']['version'] = "8.4"
  default['postgresql']['dir']         = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['client']['packages'] = ["postgresql"]
  default['postgresql']['server']['packages'] = ["postgresql"]
  default['postgresql']['server']['service_name'] = "postgresql"
end

# These defaults have disparity between which postgresql configuration
# settings are used because they were extracted from the original
# configuration files that are now removed in favor of dynamic
# generation.
#
# While the configuration ends up being the same as the default
# in previous versions of the cookbook, the content of the rendered
# template will change, and this will result in service notification
# if you upgrade the cookbook on existing systems.
#
# The ssl config attribute is generated in the recipe to avoid awkward
# merge/precedence order during the Chef run.
case node['platform_family']
when 'debian'
  default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['port'] = 5432
  default['postgresql']['config']['max_connections'] = 100
  default['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql'
  default['postgresql']['config']['shared_buffers'] = '24MB'
  default['postgresql']['config']['max_fsm_pages'] = 153600 if node['postgresql']['version'].to_f < 8.4
  default['postgresql']['config']['log_line_prefix'] = '%t '
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  default['postgresql']['config']['ssl'] = true
when 'rhel', 'fedora', 'suse'
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['max_connections'] = 100
  default['postgresql']['config']['shared_buffers'] = '32MB'
  default['postgresql']['config']['logging_collector'] = true
  default['postgresql']['config']['log_directory'] = 'pg_log'
  default['postgresql']['config']['log_filename'] = 'postgresql-%a.log'
  default['postgresql']['config']['log_truncate_on_rotation'] = true
  default['postgresql']['config']['log_rotation_age'] = '1d'
  default['postgresql']['config']['log_rotation_size'] = 0
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['lc_messages'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_monetary'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_numeric'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_time'] = 'en_US.UTF-8'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
end

default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

default['postgresql']['enable_pitti_ppa'] = false
