#
# Cookbook:: postgresql
# Library:: config
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

require 'deepsort'
require 'inifile'

module PostgreSQL
  module Cookbook
    module ConfigHelpers
      include PostgreSQL::Cookbook::Utils

      extend self

      # Enumerable deep clean proc
      ENUM_DEEP_CLEAN = proc do |*args|
        v = args.last
        v.delete_if(&ENUM_DEEP_CLEAN) if v.respond_to?(:delete_if)
        nil_or_empty?(v) && !v.is_a?(String)
      end

      # Load an INI file from disk
      #
      # @param file [String] The file to load
      # @return [Hash] File contents
      #
      def postgresql_conf_load_file(file)
        return unless ::File.exist?(file)

        ::IniFile.load(file).to_h
      end

      # Create an INI file output as a String from a Hash
      #
      # @param content [Hash] The file contents as a Hash
      # @return [String] Formatted INI output
      #
      def postgresql_conf_file_string(content, sort = true)
        raise ArgumentError, "Expected Hash got #{content.class}" unless content.is_a?(Hash)

        content_compact = content.dup.compact
        content_compact.deep_sort! if sort
        content_compact.delete_if(&ENUM_DEEP_CLEAN)

        ::IniFile.new(content: { 'global' => content_compact }).to_s.gsub("[global]\n", '')
      end
    end
  end
end
