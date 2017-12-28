# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: server_conf
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

property :version, String, default: '9.6'
property :change_notify, Symbol, default: :reload
property :hba_file, String, default: lazy { "#{data_dir}/pg_hba.conf" }
property :ident_file, String, default: lazy { "#{data_dir}/pg_ident.conf" }
property :external_pid_file, String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }

action :modify do
  template "#{data_dir}/postgresql.conf" do # ~FC037
    cookbook 'postgresql'
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies new_resource.change_notify, 'service[postgresql]', :immediately
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
