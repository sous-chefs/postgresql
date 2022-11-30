#
# Cookbook:: postgresql
# Resource:: access
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

use 'partial/_config_file'

property :config_file, String,
          default: lazy { ::File.join(conf_dir, 'pg_hba.conf') },
          desired_state: false

property :source, String,
          default: 'pg_hba.conf.erb',
          desired_state: false

property :type, String,
          required: true

property :database, String,
          required: true

property :user, String,
          required: true

property :address, String

property :auth_method, String,
          required: true

property :auth_options, [String, Hash],
          coerce: proc { |p| p.is_a?(Hash) ? p.map { |k, v| "#{k}=#{v}" }.join(' ') : p }

property :comment, String,
          desired_state: false

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?(new_resource.config_file)

  if ::File.exist?(new_resource.config_file)
    owner ::Etc.getpwuid(::File.stat(new_resource.config_file).uid).name
    group ::Etc.getgrgid(::File.stat(new_resource.config_file).gid).name
    filemode ::File.stat(new_resource.config_file).mode.to_s(8)[-4..-1]
  end

  pg_hba_file = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFile.read(new_resource.config_file)

  resource_properties = %i(type database user address auth_method auth_options)
  resource_property_values = resource_properties.map { |p| new_resource.send(p) }.compact
  entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(*resource_property_values)

  current_value_does_not_exist! unless pg_hba_file.include?(entry)

  resource_properties.each do |p|
    next unless entry.respond_to?(p)

    send(p, entry.send(p).to_s)
  end
end

action_class do
  include PostgreSQL::Cookbook::AccessHelpers::PgHbaTemplate
end

action :create do
  converge_if_changed do
    config_resource_init

    resource_properties = %i(type database user address auth_method auth_options).map { |p| new_resource.send(p) }.compact
    entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(*resource_properties)

    config_resource.variables[:pg_hba].add(entry)
  end
end

action :delete do
  config_resource_init

  resource_properties = %i(type database user address auth_method auth_options).map { |p| new_resource.send(p) }.compact
  entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(*resource_properties)

  converge_by('Remove grant entry') do
    config_resource.variables[:pg_hba].remove(entry)
  end if config_resource.variables[:pg_hba].include?(entry)
end

action(:grant) { run_action(:create) }
