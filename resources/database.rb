#
# Cookbook:: postgresql
# Resource:: user
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

resource_name :postgresql_database

property :name,     kind_of: String, name_attribute: true
property :user,     kind_of: String, default: "postgres"
property :username, kind_of: String
property :host,     kind_of: String
property :port,     kind_of: Integer
property :encoding, kind_of: String, default: "UTF-8"
property :locale,   kind_of: String, default: "en_US.UTF-8"
property :template, kind_of: String, default: "template0"
property :owner,    kind_of: String

default_action :create

action :create do
  unless database_exists?(new_resource)
    converge_by "Create PostgreSQL Database #{new_resource.name}" do
      createdb = "createdb"
      createdb << " -U #{new_resource.username}" if new_resource.username
      createdb << " -E #{new_resource.encoding}" if new_resource.encoding
      createdb << " -l #{new_resource.locale}" if new_resource.locale
      createdb << " -T #{new_resource.template}" if new_resource.template
      createdb << " -h #{new_resource.host}" if new_resource.host
      createdb << " -p #{new_resource.port}" if new_resource.port
      createdb << " -O #{new_resource.owner}" if new_resource.owner
      createdb << " #{new_resource.name}"

      execute %(create postgresql database #{new_resource.name}) do # ~FC009
        user "postgres"
        command createdb
        sensitive true
      end
    end
  end
end

action :drop do
  if database_exists?(new_resource)
    converge_by "Drop PostgreSQL Database #{new_resource.name}" do
      dropdb = "dropdb"
      dropdb << " -U #{new_resource.username}" if new_resource.username
      dropdb << " --host #{new_resource.host}" if new_resource.host
      dropdb << " --port #{new_resource.port}" if new_resource.port
      dropdb << " #{new_resource.name}"

      execute %(drop postgresql database #{new_resource.name}) do
        user "postgres"
        command dropdb
        sensitive true
      end
    end
  end
end

def database_exists?(new_resource)
  sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.name}')

  exists = %(psql -c "#{sql}" postgres)
  exists << " --host #{new_resource.host}" if new_resource.host
  exists << " --port #{new_resource.port}" if new_resource.port
  exists << " | grep #{new_resource.name}"

  cmd = Mixlib::ShellOut.new(exists, user: "postgres")
  cmd.run_command
  cmd.exitstatus.zero?
end
