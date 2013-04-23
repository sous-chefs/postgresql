#
# Cookbook Name:: postgresql
# Attributes:: default
#
# Copyright ModCloth, Inc.
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

default[:postgresql][:listen_addresses]                         = `ifconfig -a | egrep '192.168\|10.[0-9]\|172.16' | grep inet | awk '{print $2}'`.strip.to_s
default[:postgresql][:max_connections]                          = "500"
default[:postgresql][:shared_buffers]                           = "32MB"

