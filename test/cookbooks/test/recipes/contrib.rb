# frozen_string_literal: true
apt_update 'update' if platform_family?('debian')

node.default['postgresql']['password']['postgres'] = 'iloverandompasswordsbutthiswilldo'
# el6 ships 8.4 which does extensions differently and is also EOL
node.default['postgresql']['contrib']['extensions'] = %w( plpgsql xml2) unless platform_family?('rhel') && node['platform_version'].to_i < 7

include_recipe 'postgresql::contrib'
