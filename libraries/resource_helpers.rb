# frozen_string_literal: false
#
# Cookbook:: postgresql
# Library:: resource_helpers
# Author:: Dan Webb (<dan.webb@damacus.io)
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

module PostgresqlCookbook
  module Helpers
    def data_dir
      case node['platform_family']
      when 'rhel', 'fedora', 'amazon'
        "/var/lib/pgsql/#{new_resource.version}/data"
      when 'debian', 'ubuntu'
        "/var/lib/postgresql/#{new_resource.version}/main"
      end
    end

    def psql(database, query)
      "psql -d #{database} <<< '\\set ON_ERROR_STOP on\n#{query};'"
    end
  end
end
