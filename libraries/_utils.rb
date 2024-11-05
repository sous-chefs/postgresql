#
# Cookbook:: postgresql
# Library:: _utils
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

module PostgreSQL
  module Cookbook
    module Utils
      AUTH_OPTION_REGEX = /[\w-]+=(?:"[^"]*"|[^\s"]+)/

      private

      # Converts the given HBA auth-options Hash or String into its sorted string version
      #
      # @return [string] the alphanumerically sorted list of auth-options
      def sorted_auth_options_string(value)
        case value
        when Hash
          value.map { |k, v| "#{k}=#{v}" }.sort!.join(' ')
        when String
          value.scan(AUTH_OPTION_REGEX).sort!.join(' ')
        else
          raise ArgumentError, "Only Hash and String are supported, #{value.class} given."
        end
      end

      # Check if a given object(s) are either Nil or Empty
      #
      # @return [true, false] Nil or Empty check result
      #
      def nil_or_empty?(*values)
        values.any? { |v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
      end

      # Check if a given gem is installed and available for require
      #
      # @return [true, false] Gem installed result
      #
      def gem_installed?(gem_name)
        !Gem::Specification.find_by_name(gem_name).nil?
      rescue Gem::LoadError
        false
      end
    end
  end
end
