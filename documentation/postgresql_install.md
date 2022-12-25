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

| Name                               | Name? | Type            | Default | Description                                      | Allowed Values |
| ---------------------------------- | ----- | --------------- | ------- | ------------------------------------------------ | -------------- |
| `sensitive`                        |       | true, false     |         |                                                  |                |
| `version`                          |       | String, Integer |         | Version to install                               |                |
| `source`                           |       | String, Symbol  |         | Installation source                              | repo, os       |
| `client_packages`                  |       | String, Array   |         | Client packages to install                       |                |
| `server_packages`                  |       | String, Array   |         | Server packages to install                       |                |
| `repo_pgdg`                        |       | true, false     |         | Create pgdg repo                                 |                |
| `repo_pgdg_common`                 |       | true, false     |         | Create pgdg-common repo                          |                |
| `repo_pgdg_source`                 |       | true, false     |         | Create pgdg-source repo                          |                |
| `repo_pgdg_updates_testing`        |       | true, false     |         | Create pgdg-updates-testing repo                 |                |
| `repo_pgdg_source_updates_testing` |       | true, false     |         | Create pgdg-source-updates-testing repo          |                |
| `yum_gpg_key_uri`                  |       | String          |         | YUM/DNF GPG key URL                              |                |
| `apt_gpg_key_uri`                  |       | String          |         | apt GPG key URL                                  |                |
| `initdb_additional_options`        |       | String          |         | Additional options to pass to the initdb command |                |
| `initdb_locale`                    |       | String          |         | Locale to use for the initdb command             |                |
| `initdb_encoding`                  |       | String          |         | Encoding to use for the initdb command           |                |
| `initdb_user`                      |       | String          |         | User to run the initdb command as                |                |

## Libraries

- `PostgreSQL::Cookbook::Helpers`
