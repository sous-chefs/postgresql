# frozen_string_literal: true
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

# default['postgresql']['server']['config_change_notify'] = :reload
default['postgresql']['assign_postgres_password'] = true
default['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql'
default['postgresql']['config']['listen_addresses'] = 'localhost'
default['postgresql']['config']['port'] = 5432
default['postgresql']['config']['max_connections'] = 100
default['postgresql']['config']['datestyle'] = 'iso, mdy'
default['postgresql']['config']['lc_messages'] = 'en_US.UTF-8'
default['postgresql']['config']['lc_monetary'] = 'en_US.UTF-8'
default['postgresql']['config']['lc_numeric'] = 'en_US.UTF-8'
default['postgresql']['config']['lc_time'] = 'en_US.UTF-8'
default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'

# Establish default database name
default['postgresql']['database_name'] = 'template1'

case node['platform_family']
when 'debian'
  default['postgresql']['config']['shared_buffers'] = '24MB'
  default['postgresql']['config']['log_line_prefix'] = '%t '
  default['postgresql']['config']['timezone'] = 'UTC'
  default['postgresql']['config']['log_line_prefix'] = '%m [%p] %q%u@%d '
  default['postgresql']['config']['dynamic_shared_memory_type'] = 'posix'
  default['postgresql']['config']['include_dir'] = 'conf.d'
  default['postgresql']['config']['ssl'] = true
  default['postgresql']['config']['ssl_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  default['postgresql']['config']['ssl_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key'
when 'rhel', 'fedora', 'suse'
  default['postgresql']['config']['shared_buffers'] = '32MB'
  default['postgresql']['config']['logging_collector'] = true
  default['postgresql']['config']['log_directory'] = 'pg_log'
  default['postgresql']['config']['log_filename'] = 'postgresql-%a.log'
  default['postgresql']['config']['log_truncate_on_rotation'] = true
  default['postgresql']['config']['log_rotation_age'] = '1d'
  default['postgresql']['config']['log_rotation_size'] = 0
end

default['postgresql']['initdb_locale'] = 'UTF-8'
