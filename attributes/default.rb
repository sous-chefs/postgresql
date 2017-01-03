#
# Cookbook:: postgresql
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
default['postgresql']['use_pgdg_packages'] = false

default['postgresql']['server']['config_change_notify'] = :restart
default['postgresql']['assign_postgres_password'] = true

# Establish default database name
default['postgresql']['database_name'] = 'template1'

# Sets OS init system (upstart, systemd, ...), instead of relying on Ohai
default['postgresql']['server']['init_package'] =
  case node['platform']
  when 'debian'
    if node['platform_version'].to_f < 7.0
      'sysv'
    else
      'systemd'
    end
  when 'ubuntu'
    if node['platform_version'].to_f < 15.04
      'upstart'
    else
      'systemd'
    end
  when 'amazon'
    'upstart'
  when 'redhat', 'centos', 'scientific', 'oracle'
    if node['platform_version'].to_i < 7
      'sysv'
    else
      'systemd'
    end
  when 'fedora'
    'systemd'
  when 'opensuse', 'opensuseleap'
    'systemd'
  else
    'upstart'
  end

case node['platform']
when 'debian'
  if node['platform_version'].to_i == 7
    default['postgresql']['version'] = '9.1'
    default['postgresql']['dir'] = '/etc/postgresql/9.1/main'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.1', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.1']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.1']
  else # 8+
    default['postgresql']['version'] = '9.4'
    default['postgresql']['dir'] = '/etc/postgresql/9.4/main'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.4', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.4']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.4']
  end

  default['postgresql']['server']['service_name'] = 'postgresql'

when 'ubuntu'

  if node['platform_version'].to_f <= 13.10
    default['postgresql']['version'] = '9.1'
    default['postgresql']['dir'] = '/etc/postgresql/9.1/main'
    default['postgresql']['server']['service_name'] = 'postgresql'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.1', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.1']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.1']
  elsif node['platform_version'].to_f <= 14.04
    default['postgresql']['version'] = '9.3'
    default['postgresql']['dir'] = '/etc/postgresql/9.3/main'
    default['postgresql']['server']['service_name'] = 'postgresql'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.3', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.3']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.3']
  elsif node['platform_version'].to_f <= 15.10
    default['postgresql']['version'] = '9.4'
    default['postgresql']['dir'] = '/etc/postgresql/9.4/main'
    default['postgresql']['server']['service_name'] = 'postgresql'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.4', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.4']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.4']
  else
    default['postgresql']['version'] = '9.5'
    default['postgresql']['dir'] = '/etc/postgresql/9.5/main'
    default['postgresql']['server']['service_name'] = 'postgresql'
    default['postgresql']['client']['packages'] = ['postgresql-client-9.5', 'libpq-dev']
    default['postgresql']['server']['packages'] = ['postgresql-9.5']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib-9.5']
  end

when 'fedora'

  default['postgresql']['version'] = '9.5'
  default['postgresql']['setup_script'] = 'postgresql-setup'
  default['postgresql']['dir'] = '/var/lib/pgsql/data'
  default['postgresql']['client']['packages'] = %w(postgresql-devel)
  default['postgresql']['server']['packages'] = %w(postgresql-server)
  default['postgresql']['contrib']['packages'] = %w(postgresql-contrib)
  default['postgresql']['server']['service_name'] = 'postgresql'
  default['postgresql']['uid'] = '26'
  default['postgresql']['gid'] = '26'

when 'amazon'

  if node['platform_version'].to_f >= 2015.03
    default['postgresql']['version'] = '9.2'
    default['postgresql']['dir'] = '/var/lib/pgsql9/data'
  end

  default['postgresql']['client']['packages'] = %w(postgresql-devel)
  default['postgresql']['server']['packages'] = %w(postgresql-server)
  default['postgresql']['contrib']['packages'] = %w(postgresql-contrib)
  default['postgresql']['server']['service_name'] = 'postgresql'
  default['postgresql']['uid'] = '26'
  default['postgresql']['gid'] = '26'

when 'redhat', 'centos', 'scientific', 'oracle'

  default['postgresql']['version'] = '8.4'

  default['postgresql']['client']['packages'] = ['postgresql84-devel']
  default['postgresql']['server']['packages'] = ['postgresql84-server']
  default['postgresql']['contrib']['packages'] = ['postgresql84-contrib']

  default['postgresql']['setup_script'] = 'postgresql-setup'
  default['postgresql']['server']['service_name'] = 'postgresql'
  default['postgresql']['uid'] = '26'
  default['postgresql']['gid'] = '26'

  if node['platform_version'].to_f >= 6.0 && node['postgresql']['version'].to_f == 8.4
    default['postgresql']['client']['packages'] = ['postgresql-devel']
    default['postgresql']['server']['packages'] = ['postgresql-server']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib']
  end

  if node['platform_version'].to_f >= 7.0
    default['postgresql']['version'] = '9.2'
    default['postgresql']['client']['packages'] = ['postgresql-devel']
    default['postgresql']['server']['packages'] = ['postgresql-server']
    default['postgresql']['contrib']['packages'] = ['postgresql-contrib']
  end

when 'opensuse', 'opensuseleap'

  default['postgresql']['dir'] = '/var/lib/pgsql/data'
  default['postgresql']['uid'] = '26'
  default['postgresql']['gid'] = '26'

  case node['platform_version'].to_f
  when 13.1
    default['postgresql']['version'] = '9.2'
    default['postgresql']['client']['packages'] = ['postgresql92', 'postgresql92-devel']
    default['postgresql']['server']['packages'] = ['postgresql92-server']
    default['postgresql']['contrib']['packages'] = ['postgresql92-contrib']
  when 13.2
    default['postgresql']['version'] = '9.3'
    default['postgresql']['client']['packages'] = ['postgresql93', 'postgresql93-devel']
    default['postgresql']['server']['packages'] = ['postgresql93-server']
    default['postgresql']['contrib']['packages'] = ['postgresql93-contrib']
  else # opensuseleap
    default['postgresql']['version'] = '9.4'
    default['postgresql']['client']['packages'] = ['postgresql94', 'postgresql94-devel']
    default['postgresql']['server']['packages'] = ['postgresql94-server']
    default['postgresql']['contrib']['packages'] = ['postgresql94-contrib']
  end

  default['postgresql']['server']['service_name'] = 'postgresql'

when 'suse' # sles 12+
  default['postgresql']['version'] = '9.1'
  default['postgresql']['client']['packages'] = ['postgresql91', 'rubygem-pg']
  default['postgresql']['server']['packages'] = ['postgresql91-server']
  default['postgresql']['contrib']['packages'] = ['postgresql91-contrib']
  default['postgresql']['dir'] = '/var/lib/pgsql/data'
  default['postgresql']['server']['service_name'] = 'postgresql'
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
  default['postgresql']['config']['dynamic_shared_memory_type'] = 'sysv' if node['postgresql']['version'].to_f >= 9.6
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
  default['postgresql']['config']['dynamic_shared_memory_type'] = 'sysv' if node['postgresql']['version'].to_f >= 9.6
end

default['postgresql']['pg_hba'] = [
  { type: 'local', db: 'all', user: 'postgres', addr: nil, method: 'ident' },
  { type: 'local', db: 'all', user: 'all', addr: nil, method: 'ident' },
  { type: 'host', db: 'all', user: 'all', addr: '127.0.0.1/32', method: 'md5' },
  { type: 'host', db: 'all', user: 'all', addr: '::1/128', method: 'md5' },
]

default['postgresql']['password'] = {}

# set to install a specific version of the ruby gem pg
# if attribute is not defined, install will pick the latest available pg gem
default['postgresql']['pg_gem']['version'] = nil

case node['platform_family']
when 'debian'
  default['postgresql']['pgdg']['release_apt_codename'] = node['lsb']['codename']
end

default['postgresql']['initdb_locale'] = 'UTF-8'
