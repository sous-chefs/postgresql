Chef::Log.warn 'This cookbook is being re-written to use resources, not recipes and will only be Chef 13.8+ compatible. Please version pin to 6.1.1 to prevent the breaking changes from taking effect. See https://github.com/sous-chefs/postgresql/issues/512 for details'

case node['platform_family']
when 'debian'
  if node['postgresql']['version'].to_f > 9.3
    node.normal['postgresql']['enable_pgdg_apt'] = true
  end

  if node['postgresql']['enable_pgdg_apt']
    include_recipe 'postgresql::apt_pgdg_postgresql'
  end
when 'rhel', 'fedora'
  if node['postgresql']['enable_pgdg_yum']
    include_recipe 'postgresql::yum_pgdg_postgresql'
  end
end

package node['postgresql']['client']['packages']
