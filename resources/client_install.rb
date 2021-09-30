unified_mode true

property :version,    String, default: '12'
property :setup_repo, [true, false], default: true

action :install do
  postgresql_repository 'Add downloads.postgresql.org repository' do
    version new_resource.version
    only_if { new_resource.setup_repo }
  end

  case node['platform_family']
  when 'debian'
    package "postgresql-client-#{new_resource.version}"
  when 'rhel', 'fedora', 'amazon'
    ver = new_resource.version.delete('.')
    package "postgresql#{ver}"
  end
end
