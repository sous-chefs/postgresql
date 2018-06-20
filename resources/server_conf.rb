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

include PostgresqlCookbook::Helpers

property :version,              String, default: '9.6'
property :data_directory,       String, default: lazy { data_dir }
property :hba_file,             String, default: lazy { "#{conf_dir}/pg_hba.conf" }
property :ident_file,           String, default: lazy { "#{conf_dir}/pg_ident.conf" }
property :external_pid_file,    String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }
property :stats_temp_directory, String, default: lazy { "/var/run/postgresql/#{version}-main.pg_stat_tmp" }
property :additional_config,    Hash,   default: {}
property :cookbook,             String, default: 'postgresql'

action :modify do
  template "#{conf_dir}/postgresql.conf" do
    cookbook new_resource.cookbook
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    variables(
      data_dir: new_resource.data_directory,
      hba_file: new_resource.hba_file,
      ident_file: new_resource.ident_file,
      external_pid_file: new_resource.external_pid_file,
      stats_temp_directory: new_resource.stats_temp_directory,
      additional_config: new_resource.additional_config
    )
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
