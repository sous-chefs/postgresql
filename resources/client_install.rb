# frozen_string_literal: true
#
# Cookbook:: postgresql
# Resource:: client_install
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

property :version,    String, default: '9.6'
property :setup_repo, [true, false], default: true

action :install do
  postgresql_repository 'Add downloads.postgresql.org repository' do
    version new_resource.version
    only_if { new_resource.setup_repo }
  end

  case node['platform_family']
  when 'debian'
    package "postgresql-client-#{new_resource.version}"
  when 'rhel', 'fedora', 'amazon'
    ver = new_resource.version.delete('.')
    package "postgresql#{ver}"
  end
end
