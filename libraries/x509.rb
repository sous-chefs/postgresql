#
# Cookbook Name:: postgresql
# Library:: x509
# Author:: David Crane (<davidc@donorschoose.org>)
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

module Opscode
  module Postgresql
    module X509Subjects

      #######
      # Function to extract a subject line from an existing x509 certificate.
      def extract_x509_subject(crt_file)
        if ( ::File.exists?(crt_file) )
          return Chef::ShellOut.new(
             "openssl x509 -noout -in #{crt_file} -subject \
             | sed -e 's?subject= ??' \
             | tr -d '\n'"
            ).run_command.stdout
        else
          return '' # No crt_file found
        end
      end

      #######
      # Function to assemble a subject line for a new x509 certificate.
      def assemble_x509_subject(x509_spec)

        distinguished_name = []

        # Country: A two-digit code -- e.g., 'US' for the United States
        if (x509_spec.has_key?('C'))
          distinguished_name.push("C=#{x509_spec['C']}")
        end
        
        # State or Province: Full name; e.g.: 'California', not 'CA'
        if (x509_spec.has_key?('ST'))
          distinguished_name.push("ST=#{x509_spec['ST']}")
        end

        # Locality: Full name; e.g.: 'Saint Louis', not 'St. Louis'
        if (x509_spec.has_key?('L'))
          distinguished_name.push("L=#{x509_spec['L']}")
        end

        # Organization: Full legal company or personal name in your locality.
        # Spell out or omit an &, @, or any other symbol using the shift key;
        # e.g.: 'XYZ Corporation', not 'XY & Z Corporation'
        if (x509_spec.has_key?('O'))
          distinguished_name.push("O=#{x509_spec['O']}")
        end

        # Organizational Unit: Name of department or organization unit.
        # Spell out or omit an &, @, or any other symbol using the shift key.
        if (x509_spec.has_key?('OU'))
          distinguished_name.push("OU=#{x509_spec['OU']}")
        end

        # Common Name: The database's Fully Qualified Domain Name (FQDN).
        if (x509_spec.has_key?('CN'))
          distinguished_name.push("CN=#{x509_spec['CN']}")
        end

        return "/#{distinguished_name.join('/')}"

      end

# End the Opscode::Postgresql::X509Subjects module
    end
  end
end
