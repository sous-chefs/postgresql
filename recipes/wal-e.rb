#
# Cookbook Name:: postgresql
# Recipe:: wal-e

# only install the wal-e entry if we have archive mode turned on and wal-e enabled
if node['postgresql']['config']['archive_mode'] && node['postgresql']['wal_e']['enabled']
  Chef::Log.info("set up our wal-e shipper")

  missing_attrs = %w{
    aws_access_key
    aws_secret_key
    s3_bucket
  }.select do |attr|
    node['postgresql']['wal_e'][attr].nil?
  end.map { |attr| "node['postgresql']['wal_e']['#{attr}']" }

  if missing_attrs.any?
    Chef::Application.fatal!( "You must set #{missing_attrs.join(', ')}.")
  end

  include_recipe 'logrotate'

  # Save these in variables.
  myuser  = node['postgresql']['wal_e']['user']
  mygroup = node['postgresql']['wal_e']['group']

  # This is needed for wal-e even with postgres version 9.1
  # This recipe doesn't normally pull it unless postgres is greater then 9.1
  if platform_family?('ubuntu', 'debian')
    include_recipe 'postgresql::apt_pgdg_postgresql'
  end

  #install packages

  Array(node['postgresql']['wal_e']['packages']).each do |pkg|
    Chef::Log.debug("Install #{pkg} for wal-e recipe")
    package pkg
  end


  #install python modules with pip unless overriden
  unless node['postgresql']['wal_e']['pips'].nil?
    include_recipe "python::pip"
    node['postgresql']['wal_e']['pips'].each do |pip|
      Chef::Log.debug("Install pip #{pp} for wal-e recipe")
      python_pip pip
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
    revision node['postgresql']['wal_e']['git_version']
    notifies :run, "bash[install_wal_e]"
  end

  directory node['postgresql']['wal_e']['env_dir'] do
    user    myuser
    group   mygroup
    mode    "0550"
  end

  # Determine the s3 path.
  # Use s3path if it is set, else create one from s3_bucket and bkp_folder.
  s3path = case
    when node['postgresql']['wal_e']['s3_path'] && node['postgresql']['wal_e']['s3_path'][/^[sS]3:/]
      node['postgresql']['wal_e']['s3_path']
    when node['postgresql']['wal_e']['s3_path']
      "s3://" + node['postgresql']['wal_e']['s3_path']
    else
      "s3://#{node['postgresql']['wal_e']['s3_bucket']}/#{node['postgresql']['wal_e']['bkp_folder']}"
    end

  vars = {'AWS_ACCESS_KEY_ID'     => node['postgresql']['wal_e']['aws_access_key'],
          'AWS_SECRET_ACCESS_KEY' => node['postgresql']['wal_e']['aws_secret_key'],
          'WALE_S3_PREFIX'        => s3path
  }

  vars.each do |key, value|
    file "#{node['postgresql']['wal_e']['env_dir']}/#{key}" do
      content value
      user    myuser
      group   mygroup
      mode    "0440"
    end
  end

  # override our archive command
  node.default['postgresql']['config']['archive_command'] = "/usr/bin/envdir #{node['postgresql']['wal_e']['env_dir']} /usr/local/bin/wal-e wal-push %p"
  node.default['postgresql']['config']['archive_timeout'] = 60
  node.set['postgresql']['shared_archive'] = nil
  
  bb_cron = node['postgresql']['wal_e']['base_backup']
  if bb_cron
    
    cron_cmd = [
      bb_cron['flock_cmd'],   # This can be empty
      bb_cron['timeout_cmd'], # This can be empty
      # The cron command always contains the following.
      "/usr/bin/envdir #{node['postgresql']['wal_e']['env_dir']} /usr/local/bin/wal-e backup-push #{node['postgresql']['config']['data_directory']}"
    ].join(' ').strip

    # If we want to log this, ensure the log dir exists.
    if bb_cron['log_path']
      directory bb_cron['log_path'] do
        user    myuser
        group   mygroup
        mode    "0755"
      end
      
      # Rotate the wal-e backup logs once a week, keep seven of them.
      logrotate_app 'wal_e-base-backup-logrotate' do
        cookbook  'logrotate'
        path      bb_cron['log_path']
        frequency 'weekly'
        rotate    7
        create    "644 #{myuser} #{mygroup}"
      end

      # Finally, append a redirect to the log to the end of the cron command.
      cron_cmd += " >> #{bb_cron['log_path']}/wal_e-base-backup.log 2>&1"
    end

    cron "wal_e_base_backup" do
      user    myuser
      command cron_cmd
      minute  bb_cron['minute']
      hour    bb_cron['hour']
      day     bb_cron['day']
      month   bb_cron['month']
      weekday bb_cron['weekday']
    end
  end

end
