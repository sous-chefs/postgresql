[Back to resource list](../README.md#Resources)

# postgresql_server_conf

This resource manages the postgresql.conf configuration file.

## Actions

- `modify` - (default) Manage PostgreSQL configuration file (postgresql.conf)

## Properties

| Name                   | Types   | Description                             | Default                                             | Required? |
| ---------------------- | ------- | --------------------------------------- | --------------------------------------------------- | --------- |
| `additional_config`    | Hash    | Extra configuration for the config file | `{}`                                                | no        |
| `port`                 | Integer | Set listen port of PostgreSQL service   | `5432`                                              | no        |
| `version`              | String  | Version of PostgreSQL to install        | `'12'`                                              | no        |
| `data_directory`       | String  | Path of PostgreSQL data directory       | `<default_os_data_path>`                            | no        |
| `hba_file`             | String  | Path of pg_hba.conf file                | `<default_os_conf_path>/pg_hba.conf`                | no        |
| `ident_file`           | String  | Path of pg_ident.conf file              | `<default_os_conf_path>/pg_ident.conf`              | no        |
| `external_pid_file`    | String  | Path of PID file                        | `/var/run/postgresql/<postgresql_version>-main.pid` | no        |
| `stats_temp_directory` | String  | Path of stats file                      | `/var/run/postgresql/version>-main.pg_stat_tmp`     | no        |

## Examples

Setup the PostgreSQL configuration with a specific data directory:

*Note: If you have installed a specific version of PostgreSQL (different from the default version), you must specify that version in this resource too*

```ruby
postgresql_server_conf 'My PostgreSQL Config' do
  version '9.5'
  data_directory '/data/postgresql/9.5/main'
  notifies :reload, 'service[postgresql]'
end
```
