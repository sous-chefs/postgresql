#
# Cookbook Name:: postgresql_test
# Recipe:: yum_pgdg_postgresql
#
# Copyright 2013, Opscode, Inc.
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

node.set['postgresql']['enable_pgdg_yum'] = true
node.set['postgresql']['version'] = '9.2'
node.set['postgresql']['client']['packages'] = %w{postgresql92}

include_recipe "postgresql::default"
