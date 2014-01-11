#
# Cookbook Name:: postgresql
# Recipe:: server_streaming_master
#
# Author:: Jeff Harvey-Smith (<jeff@clearstorydata.com>)
# Copyright 2014, clearstorydata
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

normal['postgresql']['config']['wal_level']         = "archive"
normal['postgresql']['config']['max_wal_senders']   = 5  unless node['postgresql']['config']['max_wal_senders'].to_i   > 0
normal['postgresql']['config']['wal_keep_segments'] = 32 unless node['postgresql']['config']['wal_keep_segments'].to_i > 0

include_recipe 'postgres::server'