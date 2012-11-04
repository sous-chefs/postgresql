#
# Cookbook Name:: postgresql
# Library:: PostgresqlCookbook::SysCtlTweakCalculator
#
# Copyright 2008-2009, Opscode, Inc.
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
    class SysCtlTweakCalculator
        attr_reader :node
        def initialize a_node
            @node = a_node
        end

        def vm_swappiness
            current_swappiness = current_sysctl_or_default 'vm.swappiness', DEFAULT_SWAPPINESS
            [ POSTGRES_SWAPPINESS, current_swappiness ].min
        end

        def kernel_sem
            # Taken from my unmodified Ubuntu 12.04 workstation

            current_sem_value = current_sysctl_or_default 'kernel.sem', DEFAULT_SEM_VALUE

            (default_sems_per_set, default_system_sems, default_ops_per_semop, default_max_sets) = DEFAULT_SEM_VALUE
            (current_sems_per_set, current_system_sems, current_ops_per_semop, current_max_sets) = current_sem_value

            postgres_semaphore_sets = (node['postgresql']['max_connections'].to_i + 7) / 16

            max_semaphore_sets = [(default_max_sets + postgres_semaphore_sets), current_max_sets].max
            max_semaphores_per_set = [POSTGRES_MAX_SEMS_PER_SET, current_sems_per_set].max
            max_system_semaphores = max_semaphore_sets * max_semaphores_per_set
            max_ops_per_semop = current_ops_per_semop

            [ max_semaphores_per_set, max_system_semaphores, max_ops_per_semop, max_semaphore_sets ]
        end

        def kernel_shmall
            current_shmall = current_sysctl_or_default 'kernel.shmall', DEFAULT_SHMALL
            postgres_total_pages = MemoryConversions.mebibytes_to_pages node['postgresql']['total_memory_mb']
            [ current_shmall, postgres_total_pages ].max
        end

        def kernel_shmmax
            current_shmmax = current_sysctl_or_default 'kernel.shmmax', DEFAULT_SHMMAX
            postgres_total_memory_bytes = MemoryConversions.mebibytes_to_bytes node['postgresql']['total_memory_mb']
            [current_shmmax, postgres_total_memory_bytes].max
        end

        private
        
        DEFAULT_SWAPPINESS = 60
        DEFAULT_SEM_VALUE = [ 250, 32000, 32, 128 ]
        DEFAULT_SHMMAX = 33554432
        DEFAULT_SHMALL = 2097152

        POSTGRES_SWAPPINESS = 15
        POSTGRES_MAX_SEMS_PER_SET = 4096

        def current_sysctl_or_default path, default
            path_list = path.split('.') 
            
            if node.attribute?('sysctl')
                value = recurse_path_from node['sysctl'], path_list
            end
            
            if value.nil? && node['kernel'].attribute?('sysctl')
                value = recurse_path_from node['kernel']['sysctl'], path_list
            end

            if value 
                value
            else
                default
            end
        end

        def recurse_path_from mash, path
            first, *rest = *path
            case true
                when rest.empty? then mash[first]
                when mash[first].nil? then nil
                else recurse_path_from mash[first], rest
            end
        end
    end
end
