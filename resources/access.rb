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

unified_mode true

use 'partial/_config_file'

property :config_file, String,
          default: lazy { ::File.join(conf_dir, 'pg_hba.conf') },
          desired_state: false

property :source, String,
          default: 'pg_hba.conf.erb',
          desired_state: false

property :type, String,
          required: true,
          description: 'Access record type'

property :database, String,
          required: true,
          description: 'Access record database'

property :user, String,
          required: true,
          description: 'Access record user'

property :address, String,
          description: 'Access record address'

property :auth_method, String,
          required: true,
          description: 'Access record authentication method'

property :auth_options, [String, Hash],
          coerce: proc { |v| sorted_auth_options_string(v) },
          description: 'Access record authentication options'

property :comment, String,
          coerce: proc { |p| p.start_with?('#') ? p : "# #{p}" },
          description: 'Access record comment'

property :position, Integer,
          description: 'Access record order in file, empty spaces between positions will be truncated'

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

  %i(type database user address auth_method auth_options comment).each do |p|
    next unless entry.respond_to?(p)

    send(p, entry.send(p).to_s)
  end
  position entry.position if new_resource.position
end

action_class do
  include PostgreSQL::Cookbook::AccessHelpers::PgHbaTemplate
end

action :create do
  converge_if_changed do
    config_resource_init
    entry = config_resource.variables[:pg_hba].entry(new_resource.type, new_resource.database, new_resource.user, new_resource.address)

    if nil_or_empty?(entry)
      resource_properties = %i(type database user address auth_method auth_options comment).map { |p| [ p, new_resource.send(p) ] }.to_h.compact
      entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(**resource_properties)
      config_resource.variables[:pg_hba].add(entry, new_resource.position)
    else
      run_action(:update)
    end

    # Ensure config file is written before notifications are sent
    config_resource.run_action(:create)
  end
end

action :update do
  converge_if_changed(:auth_method, :auth_options, :comment, :position) do
    config_resource_init
    entry = config_resource.variables[:pg_hba].entry(new_resource.type, new_resource.database, new_resource.user, new_resource.address)

    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update access entry for '#{new_resource.name}' as it does not exist" if nil_or_empty?(entry)

    entry.update(auth_method: new_resource.auth_method, auth_options: new_resource.auth_options, comment: new_resource.comment)

    config_resource.variables[:pg_hba].move(entry, new_resource.position) if property_is_set?(:position)
  end
end

action :delete do
  config_resource_init

  resource_properties = %i(type database user address auth_method auth_options).map { |p| [ p, new_resource.send(p) ] }.to_h.compact
  entry = PostgreSQL::Cookbook::AccessHelpers::PgHba::PgHbaFileEntry.create(**resource_properties)

  converge_by("Remove grant entry for #{new_resource.type} | #{new_resource.database} | #{new_resource.user} | #{new_resource.auth_method}") do
    config_resource.variables[:pg_hba].remove(entry)
  end if config_resource.variables[:pg_hba].include?(entry)
end

action(:grant) { run_action(:create) }
