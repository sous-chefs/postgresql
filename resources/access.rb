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

property :source, String, required: true, default: 'pg_hba.conf.erb'
property :cookbook, String, default: 'postgresql'
property :comment, [String, nil], default: nil
property :access_type, String, required: true, default: 'local'
property :access_db, String, required: true, default: 'all'
property :access_user, String, required: true, default: 'postgres'
property :access_addr, String, required: true
property :access_method, String, required: true, default: 'ident'
property :notification, Symbol, required: true, default: :reload

action :grant do
  with_run_context :root do # ~FC037
    edit_resource(:template, "#{data_dir}/pg_hba.conf") do |new_resource|
      source new_resource.source
      cookbook new_resource.cookbook
      owner 'postgres'
      group 'postgres'
      mode '0600'
      variables['pg_hba'] ||= {}
      variables['pg_hba'] << {
        comment: new_resource.comment,
        name: new_resource.name,
        type: new_resource.access_type,
        db: new_resource.access_db,
        user: new_resource.access_user,
        addr: new_resource.access_addr,
        method: new_resource.access_method,
      }

      action :nothing
      delayed_action :create
      notifies new_resource.notification, 'service[postgresql]', :immediately
    end
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
