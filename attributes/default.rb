#
# Cookbook Name:: postgresql
# Attributes:: postgresql
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

default['postgresql']['enable_pgdg_apt'] = false
default['postgresql']['enable_pgdg_yum'] = false

default['postgresql']['server']['config_change_notify'] = :restart
default['postgresql']['assign_postgres_password'] = true

# Establish default database name
default['postgresql']['database_name'] = 'template1'

# Sets OS init system (upstart, systemd, ...), instead of relying on Ohai
default['postgresql']['server']['init_package'] = case node['platform']
  when 'debian'
    case
    when node['platform_version'].to_f < 7.0
      'sysv'
    else
      'systemd'
    end
  when 'ubuntu'
    case
    when node['platform_version'].to_f < 15.04
      'upstart'
    else
      'systemd'
    end
  when 'amazon'
    'upstart'
  when 'redhat', 'centos', 'scientific', 'oracle'
    case
    when node['platform_version'].to_f < 6.0
      'sysv'
    when node['platform_version'].to_f < 7.0
      'upstart'
    else
      'systemd'
    end
  when 'fedora'
    case
    when node['platform_version'].to_f < 15
      'upstart'
    else
      'systemd'
    end
  when 'opensuse'
    case
    when node['platform_version'].to_f < 13
      'sysv'
    else
      'systemd'
    end
  else
    'upstart'
  end

case node['platform']
when "debian"

  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    default['postgresql']['version'] = "8.3"
    default['postgresql']['dir'] = "/etc/postgresql/8.3/main"
    default['postgresql']['client']['packages'] = ["postgresql-client-8.3","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-8.3"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-8.3"]
  when node['platform_version'].to_f < 7.0 # All 6.X
    default['postgresql']['version'] = "8.4"
    default['postgresql']['dir'] = "/etc/postgresql/8.4/main"
    default['postgresql']['client']['packages'] = ["postgresql-client-8.4","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-8.4"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-8.4"]
  when node['platform_version'].to_f < 8.0 # All 7.X
    default['postgresql']['version'] = "9.1"
    default['postgresql']['dir'] = "/etc/postgresql/9.1/main"
    default['postgresql']['client']['packages'] = ["postgresql-client-9.1","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-9.1"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-9.1"]
  else
    default['postgresql']['version'] = "9.4"
    default['postgresql']['dir'] = "/etc/postgresql/9.4/main"
    default['postgresql']['client']['packages'] = ["postgresql-client-9.4","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-9.4"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-9.4"]
  end

  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    default['postgresql']['server']['service_name'] = "postgresql-8.3"
  else
    default['postgresql']['server']['service_name'] = "postgresql"
  end


when "ubuntu"

  case
  when node['platform_version'].to_f <= 9.04
    default['postgresql']['version'] = "8.3"
    default['postgresql']['dir'] = "/etc/postgresql/8.3/main"
    default['postgresql']['server']['service_name'] = "postgresql-8.3"
    default['postgresql']['client']['packages'] = ["postgresql-client-8.3","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-8.3"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-8.3"]
  when node['platform_version'].to_f <= 11.04
    default['postgresql']['version'] = "8.4"
    default['postgresql']['dir'] = "/etc/postgresql/8.4/main"
    default['postgresql']['server']['service_name'] = "postgresql"
    default['postgresql']['client']['packages'] = ["postgresql-client-8.4","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-8.4"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-8.4"]
  when node['platform_version'].to_f <= 13.10
    default['postgresql']['version'] = "9.1"
    default['postgresql']['dir'] = "/etc/postgresql/9.1/main"
    default['postgresql']['server']['service_name'] = "postgresql"
    default['postgresql']['client']['packages'] = ["postgresql-client-9.1","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-9.1"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-9.1"]
  else
    default['postgresql']['version'] = "9.3"
    default['postgresql']['dir'] = "/etc/postgresql/9.3/main"
    default['postgresql']['server']['service_name'] = "postgresql"
    default['postgresql']['client']['packages'] = ["postgresql-client-9.3","libpq-dev"]
    default['postgresql']['server']['packages'] = ["postgresql-9.3"]
    default['postgresql']['contrib']['packages'] = ["postgresql-contrib-9.3"]
  end

when "fedora"

  if node['platform_version'].to_f <= 12
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "8.4"
  end

  default['postgresql']['setup_script'] = "postgresql-setup"

  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}
  default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  default['postgresql']['server']['service_name'] = "postgresql"

when "amazon"

  if node['platform_version'].to_f == 2012.03
    default['postgresql']['version'] = "9.0"
    default['postgresql']['dir'] = "/var/lib/pgsql9/data"
  elsif node['platform_version'].to_f >= 2015.03
    default['postgresql']['version'] = "9.2"
    default['postgresql']['dir'] = "/var/lib/pgsql9/data"
  else
    default['postgresql']['version'] = "8.4"
    default['postgresql']['dir'] = "/var/lib/pgsql/data"
  end

  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}
  default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  default['postgresql']['server']['service_name'] = "postgresql"

when "redhat", "centos", "scientific", "oracle"

  default['postgresql']['version'] = "8.4"

  default['postgresql']['client']['packages'] = ["postgresql84-devel"]
  default['postgresql']['server']['packages'] = ["postgresql84-server"]
  default['postgresql']['contrib']['packages'] = ["postgresql84-contrib"]

  default['postgresql']['setup_script'] = "postgresql-setup"
  default['postgresql']['server']['service_name'] = "postgresql"

  if node['platform_version'].to_f >= 6.0 && node['postgresql']['version'].to_f == 8.4
    default['postgresql']['client']['packages'] = ['postgresql-devel']
    default['postgresql']['server']['packages'] = ['postgresql-server']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib']
  end

when "opensuse"

  default['postgresql']['dir'] = "/var/lib/pgsql/data"

  if node['platform_version'].to_f == 13.2
    default['postgresql']['version'] = '9.3'
    default['postgresql']['client']['packages'] = ['postgresql93', 'postgresql93-devel']
    default['postgresql']['server']['packages'] = ['postgresql93-server']
    default['postgresql']['contrib']['packages'] = ['postgresql93-contrib']
  elsif node['platform_version'].to_f == 13.1
    default['postgresql']['version'] = '9.2'
    default['postgresql']['client']['packages'] = ['postgresql92', 'postgresql92-devel']
    default['postgresql']['server']['packages'] = ['postgresql92-server']
    default['postgresql']['contrib']['packages'] = ['postgresql92-contrib']
  end

  default['postgresql']['server']['service_name'] = "postgresql"

when "suse"
  if node['platform_version'].to_f <= 11.1
    default['postgresql']['version'] = "8.3"
    default['postgresql']['client']['packages'] = ['postgresql', 'rubygem-pg']
    default['postgresql']['server']['packages'] = ['postgresql-server']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib']
  else
    default['postgresql']['version'] = "9.1"
    default['postgresql']['client']['packages'] = ['postgresql91', 'rubygem-pg']
    default['postgresql']['server']['packages'] = ['postgresql91-server']
    default['postgresql']['contrib']['packages'] = ['postgresql91-contrib']
  end

  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['server']['service_name'] = "postgresql"

else
  default['postgresql']['version'] = "8.4"
  default['postgresql']['dir'] = "/etc/postgresql/8.4/main"
  default['postgresql']['client']['packages'] = ["postgresql"]
  default['postgresql']['server']['packages'] = ["postgresql"]
  default['postgresql']['contrib']['packages'] = ["postgresql"]
  default['postgresql']['server']['service_name'] = "postgresql"
end

case node['platform_family']
when 'debian'
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['port'] = 5432
  default['postgresql']['config']['max_connections'] = 100
  default['postgresql']['config']['shared_buffers'] = '24MB'
  default['postgresql']['config']['log_line_prefix'] = '%t '
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  default['postgresql']['config']['ssl'] = true
when 'rhel', 'fedora', 'suse'
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['port'] = 5432
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

default['postgresql']['password'] = Hash.new

case node['platform_family']
when 'debian'
  default['postgresql']['pgdg']['release_apt_codename'] = node['lsb']['codename']
end

default['postgresql']['initdb_locale'] = 'UTF-8'

