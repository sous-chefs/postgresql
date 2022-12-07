# postgresql_install

[Back to resource list](../README.md#resources)

## Actions

- `:install`
- `:install_client`
- `:install_server`
- `:remove`
- `:remove_client`
- `:remove_server`
- `:repository`
- `:repository_create`
- `:repository_delete`
- `:init_server`

## Properties

| Name                               | Name? | Type            | Default | Description | Allowed Values |
| ---------------------------------- | ----- | --------------- | ------- | ----------- | -------------- |
| `sensitive`                        |       | true, false     |         |             |                |
| `version`                          |       | String, Integer |         |             |                |
| `source`                           |       | String, Symbol  |         |             | repo           |
| `client_packages`                  |       | String, Array   |         |             |                |
| `server_packages`                  |       | String, Array   |         |             |                |
| `repo_pgdg`                        |       | true, false     |         |             |                |
| `repo_pgdg_common`                 |       | true, false     |         |             |                |
| `repo_pgdg_source`                 |       | true, false     |         |             |                |
| `repo_pgdg_updates_testing`        |       | true, false     |         |             |                |
| `repo_pgdg_source_updates_testing` |       | true, false     |         |             |                |
| `yum_gpg_key_uri`                  |       | String          |         |             |                |
| `apt_gpg_key_uri`                  |       | String          |         |             |                |
| `initdb_additional_options`        |       | String          |         |             |                |
| `initdb_locale`                    |       | String          |         |             |                |
| `initdb_encoding`                  |       | String          |         |             |                |
| `user`                             |       | String          |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::Helpers`
