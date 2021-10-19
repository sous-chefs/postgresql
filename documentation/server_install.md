[Back to resource list](../README.md#Resources)

# postgresql_server_install

This resource installs PostgreSQL client and server packages.

## Actions

- `install` - (default) Install client and server packages
- `create` - Initialize the database

## Properties

| Name                | Types       | Description                            | Default                                            | Required? |
| ------------------- | ----------- | -------------------------------------- | -------------------------------------------------- | --------- |
| `version`           | String      | Version of PostgreSQL to install       | `'12'`                                             | no        |
| `setup_repo`        | Boolean     | Whether to add the PostgreSQL repo     | `true`                                             | no        |
| `hba_file`          | String      | Path of pg_hba.conf file               | `<default_os_path>/pg_hba.conf'`                   | no        |
| `ident_file`        | String      | Path of pg_ident.conf file             | `<default_os_path>/pg_ident.conf`                  | no        |
| `external_pid_file` | String      | Path of PID file                       | `/var/run/postgresql/<version>-main.pid</version>` | no        |
| `password`          | String, nil | Set PostgreSQL user password           | `generate`                                         | no        |
| `port`              | Integer     | Set listen port of PostgreSQL service  | `5432`                                             | no        |
| `initdb_locale`     | String      | Locale to initialize the database with | `C`                                                | no        |

## Examples

To install PostgreSQL server with default options:

```ruby
postgresql_server_install 'My PostgreSQL Server install' do
  action :install
end
```

Install PostgreSQL with a custom password and service port:

```ruby
postgresql_server_install 'Setup my PostgreSQL 9.6 server' do
  password 'MyP4ssw0rd'
  port 5433
  action :create
end
```

## Known issues

On some platforms (e.g. Ubuntu 18.04), your `initdb_locale` should be set to the
same as the template database [GH-555](https://github.com/sous-chefs/postgresql/issues/555).
