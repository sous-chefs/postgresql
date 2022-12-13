# postgresql_config

[Back to resource list](../README.md#resources)

This resource manages the postgresql.conf configuration file.

## Requires

- `deepsort`

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create`
- `:delete`

## Properties

| Name                | Name? | Type            | Default | Description                             | Allowed Values |
| ------------------- | ----- | --------------- | ------- | --------------------------------------- | -------------- |
| `config_file`       |       | String          |         |                                         |                |
| `source`            |       | String          |         |                                         |                |
| `version`           |       | String, Integer |         | PostgreSQL installed version override   |                |
| `data_directory`    |       | String          |         | PostgreSQL server data directory        |                |
| `hba_file`          |       | String          |         | PostgreSQL pg_hba.conf file location    |                |
| `ident_file`        |       | String          |         | PostgreSQL pg_ident.conf file location  |                |
| `external_pid_file` |       | String          |         | PostgreSQL external PID file location   |                |
| `server_config`     |       | Hash            |         | PostgreSQL server configuration options |                |

## Examples

Setup the PostgreSQL configuration with a specific data directory:

> Note: If you have installed a specific version of PostgreSQL (different from the default version), you must specify that version in this resource too

```ruby
postgresql_server_conf 'My PostgreSQL Config' do
  version '15'
  data_directory '/data/postgresql/15/main'
  notifies :reload, 'postgresql_service[postgresql]'
end
```
