#
# Cookbook Name:: postgresql
# Provider:: database
#

# Support whyrun
def whyrun_supported?
  true
end

action :create do
  unless @current_resource.exists
    converge_by "Create PostgreSQL Database #{new_resource.name}" do
      createdb = "createdb"
      createdb << " -U #{new_resource.username}" if new_resource.username
      createdb << " -E #{new_resource.encoding}" if new_resource.encoding
      createdb << " -l #{new_resource.locale}" if new_resource.locale
      createdb << " -T #{new_resource.template}" if new_resource.template
      createdb << " -h #{new_resource.host}" if new_resource.host
      createdb << " -p #{new_resource.port}" if new_resource.port
      createdb << " -O #{new_resource.owner}" if new_resource.owner
      createdb << " #{new_resource.name}"

      execute %(create postgresql database #{new_resource.name}) do # ~FC009
        user "postgres"
        command createdb
        sensitive true
      end

      new_resource.updated_by_last_action(true)
    end
  end
end

action :drop do
  if @current_resource.exists
    converge_by "Drop PostgreSQL Database #{new_resource.name}" do
      dropdb = "dropdb"
      dropdb << " -U #{new_resource.username}" if new_resource.username
      dropdb << " --host #{new_resource.host}" if new_resource.host
      dropdb << " --port #{new_resource.port}" if new_resource.port
      dropdb << " #{new_resource.name}"

      execute %(drop postgresql database #{new_resource.name}) do
        user "postgres"
        command dropdb
        sensitive true
      end

      new_resource.updated_by_last_action(true)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::PostgresqlDatabase.new(new_resource.name)
  @current_resource.name(new_resource.name)

  @current_resource.exists = database_exists?
end

def database_exists? # rubocop:disable AbcSize
  sql = %(SELECT datname from pg_database WHERE datname='#{new_resource.name}')

  exists = %(psql -c "#{sql}" postgres)
  exists << " --host #{new_resource.host}" if new_resource.host
  exists << " --port #{new_resource.port}" if new_resource.port
  exists << " | grep #{new_resource.name}"

  cmd = Mixlib::ShellOut.new(exists, user: "postgres")
  cmd.run_command
  cmd.exitstatus.zero?
end
