unified_mode true

include PostgresqlCookbook::Helpers

property :version,              String, default: '12'
property :data_directory,       String, default: lazy { data_dir }
property :hba_file,             String, default: lazy { "#{conf_dir}/pg_hba.conf" }
property :ident_file,           String, default: lazy { "#{conf_dir}/pg_ident.conf" }
property :external_pid_file,    String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }
property :stats_temp_directory, String, default: lazy { "/var/run/postgresql/#{version}-main.pg_stat_tmp" }
property :port,                 Integer, default: 5432
property :additional_config,    Hash,   default: {}
property :cookbook,             String, default: 'postgresql'

action :modify do
  template "#{conf_dir}/postgresql.conf" do
    cookbook new_resource.cookbook
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    variables(
      data_dir: new_resource.data_directory,
      hba_file: new_resource.hba_file,
      ident_file: new_resource.ident_file,
      external_pid_file: new_resource.external_pid_file,
      stats_temp_directory: new_resource.stats_temp_directory,
      port: new_resource.port,
      additional_config: new_resource.additional_config
    )
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
