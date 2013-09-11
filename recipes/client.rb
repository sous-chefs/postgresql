#
# Cookbook Name:: postgresql
# Recipe:: client
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011 Opscode, Inc.
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

if node['postgresql']['version'].to_f > 9.1 && ['debian', 'ubuntu'].include?(node['platform'])
  node.default['postgresql']['enable_pgdg_apt'] = true
end

case node['platform']
when "debian"

  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    node.default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f < 7.0 # All 6.X
    node.default['postgresql']['version'] = "8.4"
  else
    node.default['postgresql']['version'] = "9.1"
  end

  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    node.default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    node.default['postgresql']['server']['service_name'] = "postgresql"
  end

  node.default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  node.default['postgresql']['server']['packages'] = %w{postgresql}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}

when "ubuntu"

  case
  when node['platform_version'].to_f <= 9.04
    node.default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f <= 11.04
    node.default['postgresql']['version'] = "8.4"
  else
    node.default['postgresql']['version'] = "9.1"
  end

  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when (node['platform_version'].to_f <= 10.04) && (! node['postgresql']['enable_pgdg_apt'])
    node.default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    node.default['postgresql']['server']['service_name'] = "postgresql"
  end

  node.default['postgresql']['client']['packages'] = ["postgresql-client-#{node['postgresql']['version']}", 'libpq-dev']
  if node['postgresql']['enable_pgdg_apt'] == true
    node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']}"]
  else
    node.default['postgresql']['server']['packages'] = %w{postgresql}
  end
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}

when "fedora"

  if node['platform_version'].to_f <= 12
    node.default['postgresql']['version'] = "8.3"
  else
    node.default['postgresql']['version'] = "8.4"
  end

  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
  node.default['postgresql']['server']['packages'] = %w{postgresql-server}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  node.default['postgresql']['server']['service_name'] = "postgresql"

when "amazon"

  node.default['postgresql']['version'] = "8.4"
  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
  node.default['postgresql']['server']['packages'] = %w{postgresql-server}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  node.default['postgresql']['server']['service_name'] = "postgresql"

when "redhat", "centos", "scientific", "oracle"

  node.default['postgresql']['version'] = "8.4"
  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"

  if node['platform_version'].to_f >= 6.0
    node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
    node.default['postgresql']['server']['packages'] = %w{postgresql-server}
    node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  else
    node.default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
    node.default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
    node.default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
  end
  node.default['postgresql']['server']['service_name'] = "postgresql"

when "suse"

  if node['platform_version'].to_f <= 11.1
    node.default['postgresql']['version'] = "8.3"
  else
    node.default['postgresql']['version'] = "9.0"
  end

  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
  node.default['postgresql']['server']['packages'] = %w{postgresql-server}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  node.default['postgresql']['server']['service_name'] = "postgresql"

else
  node.default['postgresql']['version'] = "8.4"
  node.default['postgresql']['dir']         = "/etc/postgresql/#{node['postgresql']['version']}/main"
  node.default['postgresql']['client']['packages'] = ["postgresql"]
  node.default['postgresql']['server']['packages'] = ["postgresql"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql"]
  node.default['postgresql']['server']['service_name'] = "postgresql"
end

# These node.defaults have disparity between which postgresql configuration
# settings are used because they were extracted from the original
# configuration files that are now removed in favor of dynamic
# generation.
#
# While the configuration ends up being the same as the node.default
# in previous versions of the cookbook, the content of the rendered
# template will change, and this will result in service notification
# if you upgrade the cookbook on existing systems.
#
# The ssl config attribute is generated in the recipe to avoid awkward
# merge/precedence order during the Chef run.
case node['platform_family']
when 'debian'
  node.default['postgresql']['pgdg']['release_apt_codename'] = node['lsb']['codename']

  node.default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  node.default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  node.default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  node.default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  node.default['postgresql']['config']['listen_addresses'] = 'localhost'
  node.default['postgresql']['config']['port'] = 5432
  node.default['postgresql']['config']['max_connections'] = 100
  node.default['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql'
  node.default['postgresql']['config']['shared_buffers'] = '24MB'
  node.default['postgresql']['config']['max_fsm_pages'] = 153600 if node['postgresql']['version'].to_f < 8.4
  node.default['postgresql']['config']['log_line_prefix'] = '%t '
  node.default['postgresql']['config']['datestyle'] = 'iso, mdy'
  node.default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  node.default['postgresql']['config']['ssl'] = true
when 'rhel', 'fedora', 'suse'
  node.default['postgresql']['config']['listen_addresses'] = 'localhost'
  node.default['postgresql']['config']['max_connections'] = 100
  node.default['postgresql']['config']['shared_buffers'] = '32MB'
  node.default['postgresql']['config']['logging_collector'] = true
  node.default['postgresql']['config']['log_directory'] = 'pg_log'
  node.default['postgresql']['config']['log_filename'] = 'postgresql-%a.log'
  node.default['postgresql']['config']['log_truncate_on_rotation'] = true
  node.default['postgresql']['config']['log_rotation_age'] = '1d'
  node.default['postgresql']['config']['log_rotation_size'] = 0
  node.default['postgresql']['config']['datestyle'] = 'iso, mdy'
  node.default['postgresql']['config']['lc_messages'] = 'en_US.UTF-8'
  node.default['postgresql']['config']['lc_monetary'] = 'en_US.UTF-8'
  node.default['postgresql']['config']['lc_numeric'] = 'en_US.UTF-8'
  node.default['postgresql']['config']['lc_time'] = 'en_US.UTF-8'
  node.default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
end

if(node['postgresql']['enable_pgdg_apt'])
  include_recipe 'postgresql::apt_pgdg_postgresql'
end

if(node['postgresql']['enable_pgdg_yum'])
  include_recipe 'postgresql::yum_pgdg_postgresql'
end

node['postgresql']['client']['packages'].each do |pg_pack|

  package pg_pack

end
