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

<!-- markdownlint-disable MD034 -->
| Name                                     | Name? | Type            | Default           | Description                                      | Allowed Values |
| ---------------------------------------- | ----- | --------------- | ----------------- | ------------------------------------------------ | -------------- |
| `sensitive`                              |       | true, false     | `true`            |                                                  |                |
| `version`                                |       | String, Integer | `'17'`            | Version to install                               |                |
| `source`                                 |       | String, Symbol  | `:repo`           | Installation source                              | repo, os       |
| `client_packages`                        |       | String, Array   | platform specific | Client packages to install                       |                |
| `server_packages`                        |       | String, Array   | platform specific | Server packages to install                       |                |
| `repo_pgdg`                              |       | true, false     | `true`            | Create pgdg repo                                 |                |
| `setup_repo_pgdg`                        |       | true, false     | value of previous | Whether or not to manage the pgdg repo           |                |
| `repo_pgdg_common`                       |       | true, false     | `true`            | Create pgdg-common repo                          |                |
| `setup_repo_pgdg_common`                 |       | true, false     | value of previous | Whether or not to manage the pgdg_common repo    |                |
| `repo_pgdg_source`                       |       | true, false     | `false`           | Create pgdg-source repo                          |                |
| `setup_repo_pgdg_source`                 |       | true, false     | value of previous | Whether or not to manage the pgdg_source repo    |                |
| `repo_pgdg_updates_testing`              |       | true, false     | `false`           | Create pgdg-updates-testing repo                 |                |
| `setup_repo_pgdg_updates_testing`        |       | true, false     | value of previous | Whether or not to manage the pgdg_updates_testing repo |          |
| `repo_pgdg_source_updates_testing`       |       | true, false     | `false`           | Create pgdg-source-updates-testing repo          |                |
| `setup_repo_pgdg_source_updates_testing` |       | true, false     | value of previous | Whether or not to manage the pgdg_source_updates_testing repo |   |
| `yum_gpg_key_uri`                        |       | String          | platform specific | YUM/DNF GPG key URL                              |                |
| `apt_repository_uri`                     |       | String          | https://download.postgresql.org/pub/repos/apt/ | apt repository URL  |                |
| `apt_gpg_key_uri`                        |       | String          | https://download.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt GPG key URL |        |
| `initdb_additional_options`              |       | String          |                   | Additional options to pass to the initdb command |                |
| `initdb_locale`                          |       | String          |                   | Locale to use for the initdb command             |                |
| `initdb_encoding`                        |       | String          |                   | Encoding to use for the initdb command           |                |
| `initdb_user`                            |       | String          | `'postgres'`      | User to run the initdb command as                |                |
<!-- markdownlint-enable MD034 -->

## Libraries

- `PostgreSQL::Cookbook::Helpers`
