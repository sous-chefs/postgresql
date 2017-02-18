# frozen_string_literal: true
node.default['postgresql']['enable_pgdg_yum'] = true
node.default['postgresql']['version'] = '9.4'
node.default['postgresql']['client']['packages'] = 'postgresql94'

include_recipe 'postgresql::default'
