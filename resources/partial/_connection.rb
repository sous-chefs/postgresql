#
# Cookbook:: postgresql
# Partial:: _connection
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

unified_mode true

property :host, String,
          desired_state: false,
          description: 'PostgreSQL server hostname'

property :port, Integer,
          default: 5432,
          desired_state: false,
          description: 'PostgreSQL server port number'

property :options, Hash,
          desired_state: false,
          description: 'PostgreSQL backend options'

property :dbname, String,
          desired_state: false,
          description: 'PostgreSQL database name'

property :user, String,
          default: 'postgres',
          desired_state: false,
          description: 'PostgreSQL login user name'

property :password, String,
          desired_state: false,
          description: 'PostgreSQL login password'

property :connection_string, String,
          desired_state: false,
          description: 'PostgreSQL server connection string'

property :force, [true, false],
          desired_state: false,
          description: 'SQL command FORCE'
