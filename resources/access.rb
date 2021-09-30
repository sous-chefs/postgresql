unified_mode true

property :access_type,   String, default: 'local'
property :access_db,     String, default: 'all'
property :access_user,   String, default: 'postgres'
property :access_method, String, default: 'ident'
property :cookbook,      String, default: 'postgresql'
property :source,        String, default: 'pg_hba.conf.erb'
property :access_addr,   String
property :comment,       String

action :grant do
  config_resource = new_resource
  with_run_context :root do
    edit_resource(:template, "#{conf_dir}/pg_hba.conf") do |new_resource|
      source new_resource.source
      cookbook new_resource.cookbook
      owner 'postgres'
      group 'postgres'
      mode '0600'
      variables[:pg_hba] ||= {}
      variables[:pg_hba][new_resource.name] = {
        comment: new_resource.comment,
        type: new_resource.access_type,
        db: new_resource.access_db,
        user: new_resource.access_user,
        addr: new_resource.access_addr,
        method: new_resource.access_method,
      }
      action :nothing
      delayed_action :create
      notifies :trigger, config_resource, :immediately
    end
  end
end

action :trigger do
  new_resource.updated_by_last_action(true)
end

action_class do
  include PostgresqlCookbook::Helpers
end
