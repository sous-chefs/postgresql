#
# cookbook name:: postgresql
# recipe:: plpython
#
# licensed under the apache license, version 2.0 (the "license");
# you may not use this file except in compliance with the license.
# you may obtain a copy of the license at
#
#     http://www.apache.org/licenses/license-2.0
#
# unless required by applicable law or agreed to in writing, software
# distributed under the license is distributed on an "as is" basis,
# without warranties or conditions of any kind, either express or implied.
# see the license for the specific language governing permissions and
# limitations under the license.

include_recipe "postgresql::server"

# Install the PostgreSQL plpython package(s) from the distribution,
# as specified by the node attributes.
node['postgresql']['plpython']['packages'].each do |pg_pack|

  package pg_pack

end
