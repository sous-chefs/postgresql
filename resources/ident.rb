# frozen_string_literal: true
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

property :mapname,       String, name_property: true
property :source,        String, required: true, default: 'pg_ident.conf.erb'
property :cookbook,      String, default: 'postgresql'
property :system_user,   String, required: true
property :pg_user,       String, required: true
property :comment,       [String, nil], default: nil
property :notification,  Symbol, default: :reload

action :create do
  with_run_context :root do # ~FC037
    edit_resource(:template, "#{conf_dir}/pg_ident.conf") do |new_resource|
      source new_resource.source
      cookbook new_resource.cookbook
      owner 'postgres'
      group 'postgres'
      mode '0640'
      variables['pg_ident'] ||= {}
      variables['pg_ident'][new_resource.name] = {
        comment: new_resource.comment,
        mapname: new_resource.mapname,
        system_user: new_resource.system_user,
        pg_user: new_resource.pg_user,
      }
      action :nothing
      delayed_action :create
      notifies new_resource.notification, postgresql_service
    end
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
