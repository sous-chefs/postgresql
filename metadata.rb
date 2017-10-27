# frozen_string_literal: true
name              'postgresql'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs and configures postgresql for clients or servers'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '6.1.1'
source_url        'https://github.com/sous-chefs/postgresql'
issues_url        'https://github.com/sous-chefs/postgresql/issues'
chef_version      '>= 12.14' if respond_to?(:chef_version)

%w(ubuntu debian fedora amazon redhat centos scientific oracle).each do |os|
  supports os
end

depends 'build-essential', '>= 2.0.0'
depends 'openssl', '>= 4.0'
