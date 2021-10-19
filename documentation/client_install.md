[Back to resource list](../README.md#Resources)

# postgresql_client_install

This resource installs PostgreSQL client packages.

## Actions

- `install` - (default) Install client packages

## Properties

| Name                | Types       | Description                                                   | Default                                   | Required? |
| ------------------- | ----------- | ------------------------------------------------------------- | ----------------------------------------- | --------- |
| `version`           | String      | Version of PostgreSQL to install                              | `'12'`                                    | no        |
| `setup_repo`        | Boolean     | whether to add the PostgreSQL repo                            | `true`                                    | no        |
| `hba_file`          | String      |                                                               | `#{conf_dir}/main/pg_hba.conf`            | no        |
| `ident_file`        | String      |                                                               | `#{conf_dir}/main/pg_ident.conf`          | no        |
| `external_pid_file` | String      |                                                               | `/var/run/postgresql/#{version}-main.pid` | no        |
| `password`          | String, nil | Pass in a password, or have the cookbook generate one for you | Random string                             | no        |

## Examples

To install version 9.5:

```ruby
postgresql_client_install 'My PostgreSQL Client install' do
  version '9.5'
end
```
