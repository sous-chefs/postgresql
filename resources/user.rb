# frozen_string_literal: true
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

property :superuser,          [TrueClass, FalseClass], default: false
property :createdb,           [TrueClass, FalseClass], default: false
property :createrole,         [TrueClass, FalseClass], default: false
property :inherit,            [TrueClass, FalseClass], default: true
property :replication,        [TrueClass, FalseClass], default: false
property :login,              [TrueClass, FalseClass], default: true
property :password,           String
property :encrypted_password, String

action :create do
  execute "create postgresql user #{new_resource.name}" do # ~FC009
    user 'postgres'
    command %(psql -c "CREATE ROLE #{role_sql(new_resource)}")
    sensitive true
    not_if { user_exists?(new_resource) }
  end
end

action :update do
  execute "update postgresql user #{new_resource.name}" do
    user 'postgres'
    command %(psql -c "ALTER ROLE #{role_sql(new_resource)}")
    sensitive true
    only_if { user_exists?(new_resource) }
  end
end

action :drop do
  execute "drop postgresql user #{new_resource.name}" do
    user 'postgres'
    command %(psql -c 'DROP ROLE IF EXISTS \\\"#{new_resource.name}\\\"')
    sensitive true
    only_if { user_exists?(new_resource) }
  end
end

action_class do
  def user_exists?(new_resource)
    exists = %(psql -c "SELECT rolname FROM pg_roles WHERE rolname='#{new_resource.name}'" | grep '#{new_resource.name}')

    cmd = Mixlib::ShellOut.new(exists, user: 'postgres')
    cmd.run_command
    cmd.exitstatus == 0
  end

  def role_sql(new_resource)
    sql = %(\\\"#{new_resource.name}\\\" )

    %w(superuser createdb createrole inherit replication login).each do |perm|
      sql << "#{'NO' unless new_resource.send(perm)}#{perm.upcase} "
    end

    sql << if new_resource.encrypted_password
             "ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'"
           elsif new_resource.password
             "PASSWORD '#{new_resource.password}'"
           else
             ''
           end
  end
end
