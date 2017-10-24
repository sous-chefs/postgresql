# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: config
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

property :config_directory, String, required: true
property :change_notify, String, default: 'restart'
property :pg_hba, Array, default: []
property :postgresql, Hash, default: {}

action :manage do
  template "#{config_directory}/postgresql.conf" do
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies change_notify, 'service[postgresql]', :immediately
  end

  template "#{config_directory}/pg_hba.conf" do
    source 'pg_hba.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies change_notify, 'service[postgresql]', :immediately
  end
end
