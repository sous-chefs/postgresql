#
# Cookbook Name:: postgresql
# Library:: PostgresqlCookbook::MemoryConversions
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
    module MemoryConversions
        def self.kibibytes_to_mebibytes kib
            kib / 1024
        end

        def self.mebibytes_to_bytes mib
            mib * 1024 * 1024
        end

        def self.mebibytes_to_pages mib
            (mebibytes_to_bytes mib) / PAGE_SIZE
        end

        PAGE_SIZE = 4096
    end
end
