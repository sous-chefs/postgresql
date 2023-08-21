#
# Cookbook:: postgresql
# Resource:: ident
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
          default: lazy { ::File.join(conf_dir, 'pg_ident.conf') }

property :source, String,
          default: 'pg_ident.conf.erb'

property :map_name, String,
          name_property: true,
          description: 'Arbitrary name that will be used to refer to this mapping in pg_hba.conf'

property :system_username, String,
          required: true,
          description: 'Operating system user name '

property :database_username, String,
          required: true,
          description: 'Database user name '

property :comment, String,
          coerce: proc { |p| p.start_with?('#') ? p : "# #{p}" },
          description: 'Ident mapping record comment'

load_current_value do |new_resource|
  current_value_does_not_exist! unless ::File.exist?(new_resource.config_file)

  if ::File.exist?(new_resource.config_file)
    owner ::Etc.getpwuid(::File.stat(new_resource.config_file).uid).name
    group ::Etc.getgrgid(::File.stat(new_resource.config_file).gid).name
    filemode ::File.stat(new_resource.config_file).mode.to_s(8)[-4..-1]
  end

  ident_file = PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFile.read(new_resource.config_file)

  current_value_does_not_exist! unless ident_file.entry?(new_resource.map_name)

  entry = ident_file.entry(new_resource.map_name)
  %i(map_name system_username database_username comment).each { |p| send(p, entry.send(p)) }
end

action_class do
  include PostgreSQL::Cookbook::IdentHelpers::PgIdentTemplate
end

action :create do
  converge_if_changed do
    config_resource_init
    entry = config_resource.variables[:pg_ident].entry(new_resource.map_name)

    if nil_or_empty?(entry)
      resource_properties = %i(map_name system_username database_username comment).map { |p| [ p, new_resource.send(p) ] }.to_h.compact
      entry = PostgreSQL::Cookbook::IdentHelpers::PgIdent::PgIdentFileEntry.new(**resource_properties)
      config_resource.variables[:pg_ident].add(entry)
    else
      entry.update(system_username: new_resource.system_username, database_username: new_resource.database_username, comment: new_resource.comment)
    end
  end
end

action :update do
  converge_if_changed(:system_username, :database_username, :comment) do
    config_resource_init
    entry = config_resource.variables[:pg_ident].entry(new_resource.map_name)

    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update ident entry for '#{new_resource.map_name}' as it does not exist" if nil_or_empty?(entry)

    entry.update(system_username: new_resource.system_username, database_username: new_resource.database_username, comment: new_resource.comment)
  end
end

action :delete do
  config_resource_init

  converge_by("Remove ident entry with map_name: #{new_resource.map_name}") do
    config_resource.variables[:pg_ident].remove(new_resource.map_name)
  end if config_resource.variables[:pg_ident].entry?(new_resource.map_name)
end
