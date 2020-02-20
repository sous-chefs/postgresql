# frozen_string_literal: true
name              'postgresql'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs and configures postgresql for clients or servers'
version           '7.1.5'
source_url        'https://github.com/sous-chefs/postgresql'
issues_url        'https://github.com/sous-chefs/postgresql/issues'
chef_version      '>= 13.8'

%w(ubuntu debian fedora amazon redhat centos scientific oracle).each do |os|
  supports os
end
