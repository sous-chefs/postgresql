unified_mode true

property :mapname,     String, required: true
property :source,      String, default: 'pg_ident.conf.erb'
property :cookbook,    String, default: 'postgresql'
property :system_user, String, required: true
property :pg_user,     String, required: true
property :comment,     String

action :create do
  ident_resource = new_resource
  with_run_context :root do
    edit_resource(:template, "#{conf_dir}/pg_ident.conf") do |new_resource|
      source new_resource.source
      cookbook new_resource.cookbook
      owner 'postgres'
      group 'postgres'
      mode '0640'
      variables[:pg_ident] ||= {}
      variables[:pg_ident][new_resource.name] = {
        comment: new_resource.comment,
        mapname: new_resource.mapname,
        system_user: new_resource.system_user,
        pg_user: new_resource.pg_user,
      }
      action :nothing
      delayed_action :create
      notifies :trigger, ident_resource, :immediately
    end
  end
end

action :trigger do
  new_resource.updated_by_last_action(true)
end

action_class do
  include PostgresqlCookbook::Helpers
end
