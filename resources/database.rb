# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: database
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

# name property should take the form:
# database/extension

property :database, String, name_property: true, default: lazy { name.scan(%r{\A[^/]+(?=/)}).first }
property :username, String, default: 'postgres'
property :encoding, String, default: 'UTF-8'
property :locale, String, default: 'en_US.UTF-8'
property :template, String, default: ''
property :host, String
property :port, [String, Integer], default: ''
property :owner, String

action :create do
  createdb = "createdb"
  createdb << " -U #{new_resource.username}" if new_resource.username
  createdb << " -E #{new_resource.encoding}" if new_resource.encoding
  createdb << " -l #{new_resource.locale}" if new_resource.locale
  createdb << " -T #{new_resource.template}" if new_resource.template
  createdb << " -h #{new_resource.host}" if new_resource.host
  createdb << " -p #{new_resource.port}" if new_resource.port
  createdb << " -O #{new_resource.owner}" if new_resource.owner
  createdb << " #{new_resource.name}"

  bash "Create Database #{new_resource.database}" do
    code createdb
    user new_resource.username
    not_if { database_exists? }
    sensitive true
  end

end

action :drop do
  if @current_resource.exists
    converge_by "Drop PostgreSQL Database #{new_resource.database}" do
      dropdb = "dropdb"
      dropdb << " -U #{new_resource.username}" if new_resource.username
      dropdb << " --host #{new_resource.host}" if new_resource.host
      dropdb << " --port #{new_resource.port}" if new_resource.port
      dropdb << " #{new_resource.database}"

      execute %(drop postgresql database #{new_resource.database}) do
        user "postgres"
        command dropdb
        sensitive true
      end

      new_resource.updated_by_last_action(true)
    end
  end
end

action_class do
  include PostgresqlCookbook::Helpers

  def extension_installed?
    query = "SELECT 'installed' FROM pg_extension WHERE extname = '#{new_resource.extension}';"
    !(execute_sql(query, new_resource.database) =~ /^installed$/).nil?
  end
end
