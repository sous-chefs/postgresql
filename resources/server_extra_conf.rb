# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: extra_conf
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

property :extra_config_name, String, required: true
property :notification, Symbol, required: true, default: :restart

action :modify do
  template "#{conf_dir}/conf.d/#{new_ressource.extra_config_name}.conf" do # ~FC037
    cookbook 'postgresql'
    source 'postgresql_extra_config.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    variables(
      extra_config_name: new_resource.extra_config_name
    )
    notifies new_resource.notification, postgresql_service
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
