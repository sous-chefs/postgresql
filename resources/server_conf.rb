
property :version, String, default: '9.6'
property :change_notify, Symbol, default: :restart
property :hba_file, String, default: lazy { "#{data_dir}/pg_hba.conf" }
property :ident_file, String, default: lazy { "#{data_dir}/pg_ident.conf" }
property :external_pid_file, String, default: lazy { "/var/run/postgresql/#{version}-main.pid" }

action :modify do
  template "#{data_dir}/postgresql.conf" do # ~FC037
    cookbook 'postgresql'
    source 'postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0600'
    notifies new_resource.change_notify, 'service[postgresql]', :immediately
  end
end

action_class do
  include PostgresqlCookbook::Helpers
end
