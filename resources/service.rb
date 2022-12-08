#
# Cookbook:: postgresql
# Resource:: service
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

include PostgreSQL::Cookbook::Helpers

property :service_name, String,
          default: lazy { default_platform_service_name },
          description: 'Service name to perform actions for'

property :delay_start, [true, false],
          default: true,
          description: 'Delay service start until end of run'

action_class do
  def do_service_action(resource_action)
    if %i(start restart reload).include?(resource_action) && new_resource.delay_start
      declare_resource(:service, new_resource.service_name) do
        supports status: true, restart: true, reload: true

        delayed_action resource_action
      end
    else
      declare_resource(:service, new_resource.service_name) do
        supports status: true, restart: true, reload: true

        action resource_action
      end
    end
  end
end

%i(start stop restart reload enable disable).each do |action_type|
  send(:action, action_type) { do_service_action(action) }
end
