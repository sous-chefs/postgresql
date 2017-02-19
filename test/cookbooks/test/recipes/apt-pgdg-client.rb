# frozen_string_literal: true
apt_update 'update' if platform_family?('debian')

node.default['postgresql']['enable_pgdg_apt'] = true
node.default['postgresql']['version'] = '9.4'
node.default['postgresql']['client']['packages'] = ['postgresql-client-9.4', 'libpq-dev']

include_recipe 'postgresql::default'
