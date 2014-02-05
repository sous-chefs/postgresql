#
# Cookbook Name:: wal-e
# Recipe:: default

# only install the cron entry if we have archive mode turned on
archive_mode = node['postgresql']['config']['archive_mode']
if archive_mode
  Chef::Log.info("set up our wal-e shipper")

  missing_attrs = %w{
    aws_access_key
    aws_secret_key
    s3_bucket
  }.select do |attr|
    node['postgresql']['wal_e'][attr].nil?
  end.map { |attr| "node['postgresql']['wal_e']['#{attr}']" }

  if !missing_attrs.empty?
    Chef::Application.fatal!( "You must set #{missing_attrs.join(', ')}.")
  end

  # This is needed for wal-e even with postgres version 9.1
  # This recipe doesn't normally pull it unless postgres is greater then 9.1
  if platform_family?('ubuntu', 'debian')
    include_recipe 'postgresql::apt_pgdg_postgresql'
  end

  #install packages
  node['postgresql']['wal_e']['packages'].each do |pkg|
    Chef::Log.debug("Install #{pkg} for wal-e recipe")
    package pkg
  end

  #install python modules with pip unless overriden
  unless node['postgresql']['wal_e']['pips'].nil?
    include_recipe "python::pip"
    node['postgresql']['wal_e']['pips'].each do |pp|
      python_pip "gevent"
    end
  end

  code_path = "#{Chef::Config[:file_cache_path]}/wal-e"

  bash "install_wal_e" do
    cwd code_path
    code <<-EOH
      /usr/bin/python ./setup.py install
    EOH
    action :nothing
  end

  git code_path do
    repository "https://github.com/wal-e/wal-e.git"
    revision "v0.6.5"
    notifies :run, "bash[install_wal_e]"
  end

  directory node['postgresql']['wal_e']['env_dir'] do
    user    node['postgresql']['wal_e']['user']
    group   node['postgresql']['wal_e']['group']
    mode    "0550"
  end

  vars = {'AWS_ACCESS_KEY_ID'     => node['postgresql']['wal_e']['aws_access_key'],
          'AWS_SECRET_ACCESS_KEY' => node['postgresql']['wal_e']['aws_secret_key'],
          'WALE_S3_PREFIX'        => "s3://#{node['postgresql']['wal_e']['s3_bucket']}/#{node['postgresql']['wal_e']['bkp_folder']}"
  }

  vars.each do |key, value|
    file "#{node['postgresql']['wal_e']['env_dir']}/#{key}" do
      content value
      user    node['postgresql']['wal_e']['user']
      group   node['postgresql']['wal_e']['group']
      mode    "0440"
    end
  end

  # override our archive command
  node.default['postgresql']['config']['archive_command'] = "/usr/bin/envdir #{node['postgresql']['wal_e']['env_dir']} /usr/local/bin/wal-e wal-push %p"
  node.default['postgresql']['config']['archive_timeout'] = 60
  node.set['postgresql']['shared_archive'] = nil
  
  bb_cron = node['postgresql']['wal_e']['base_backup']
  cron "wal_e_base_backup" do
    user node['postgresql']['wal_e']['user']
    command "/usr/bin/envdir #{node['postgresql']['wal_e']['env_dir']} /usr/local/bin/wal-e backup-push #{node['postgresql']['config']['data_directory']}"

    minute  bb_cron['minute']
    hour    bb_cron['hour']
    day     bb_cron['day']
    month   bb_cron['month']
    weekday bb_cron['weekday']
  end

end
