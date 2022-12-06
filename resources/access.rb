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
  entry = pg_hba_file.entry(new_resource.type, new_resource.database, new_resource.user, new_resource.address)

  current_value_does_not_exist! if nil_or_empty?(entry)

  %i(type database user address auth_method auth_options).each do |p|
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
    entry = config_resource.variables[:pg_hba].entry(new_resource.type, new_resource.database, new_resource.user, new_resource.address)

    if nil_or_empty?(entry)
      resource_properties = %i(type database user address auth_method auth_options).map { |p| new_resource.send(p) }.compact
      entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(*resource_properties)
      config_resource.variables[:pg_hba].add(entry)
    else
      entry.update(new_resource.auth_method, new_resource.auth_options)
    end
  end
end

action :update do
  converge_if_changed(:auth_method, :auth_options) do
    config_resource_init
    entry = config_resource.variables[:pg_hba].entry(new_resource.type, new_resource.database, new_resource.user, new_resource.address)

    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update access entry '#{new_resource.name}' as it does not exist" if nil_or_empty?(entry)

    entry.update(new_resource.auth_method, new_resource.auth_options)
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
