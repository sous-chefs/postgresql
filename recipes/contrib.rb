#
# Cookbook:: postgresql
# Recipe:: contrib
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

db_name = node['postgresql']['database_name']

# Install the PostgreSQL contrib package(s) from the distribution,
# as specified by the node attributes.
package node['postgresql']['contrib']['packages']

include_recipe 'postgresql::server'

# Install PostgreSQL contrib extentions into the database, as specified by the
# node attribute node['postgresql']['database_name'].
if node['postgresql']['contrib'].attribute?('extensions')
  node['postgresql']['contrib']['extensions'].each do |pg_ext|
    postgresql_extension "#{db_name}/#{pg_ext}"
  end
end
