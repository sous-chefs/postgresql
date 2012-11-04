#
# Cookbook Name:: postgresql
# Recipe:: postgresql::sysctl
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
calculator = PostgresqlCookbook::SysCtlTweakCalculator.new node

Chef::Log.debug <<-EOM
Tuning sysctl parameters:
    kernel.sem = #{calculator.kernel_sem}
    kernel.shmall = #{calculator.kernel_shmall}
    kernel.shmmax = #{calculator.kernel_shmmax}
    vm.swappiness = #{calculator.vm_swappiness}
EOM

node.set['sysctl']['kernel']['sem'] = calculator.kernel_sem
node.set['sysctl']['kernel']['shmall'] = calculator.kernel_shmall
node.set['sysctl']['kernel']['shmmax'] = calculator.kernel_shmmax
node.set['sysctl']['vm']['swappiness'] = calculator.vm_swappiness
node.save unless Chef::Config.solo

include_recipe 'sysctl::default'

#FIXME: This is a workaround for a bug in the currently released version of the
#sysctl recipe (0.1.0). A pull request
#(https://github.com/Fewbytes/sysctl-cookbook/pulls/3) has been submitted for that cookbook, but
#to make sure that the changes the the syctl settings are applied, we force procps to run.

service 'procps' do
    action :start
end
