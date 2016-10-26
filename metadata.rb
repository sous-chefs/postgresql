name              'postgresql'
maintainer        'Heavy Water Operations, LLC'
maintainer_email  'helpdesk@heavywater.io'
license           'Apache 2.0'
description       'Installs and configures postgresql for clients or servers'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '5.0.1'
source_url        'https://github.com/hw-cookbooks/postgresql' if respond_to?(:source_url)
issues_url        'https://github.com/hw-cookbooks/postgresql/issues' if respond_to?(:issues_url)
chef_version      '>= 11.0' if respond_to?(:chef_version)
recipe            'postgresql', 'Includes postgresql::client'
recipe            'postgresql::ruby', 'Installs pg gem for Ruby bindings'
recipe            'postgresql::client', 'Installs postgresql client package(s)'
recipe            'postgresql::server', 'Installs postgresql server packages, templates'

supports 'ubuntu', '>= 12.04'
supports 'debian', '>= 7.0'
supports 'opensuse', '>= 13.0'
supports 'suse', '>= 12.0'

%w(fedora opensuseleap opensuse amazon).each do |os|
  supports os
end

%w(redhat centos scientific oracle).each do |el|
  supports el, '>= 6.0'
end

depends 'apt', '>= 1.9.0'
depends 'build-essential', '>= 2.0.0'
depends 'openssl', '>= 4.0'
