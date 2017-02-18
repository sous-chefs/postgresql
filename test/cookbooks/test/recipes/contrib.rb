# frozen_string_literal: true
apt_update 'update' if platform_family?('debian')

node.default['postgresql']['password']['postgres'] = 'iloverandompasswordsbutthiswilldo'
node.default['postgresql']['contrib']['extensions'] = %w( plpgsql xml2)

include_recipe 'postgresql::contrib'
