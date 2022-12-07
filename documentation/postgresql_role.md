# postgresql_role

[Back to resource list](../README.md#resources)

## Uses

- [partial/_connection](partial/_connection.md)

## Provides

- :postgresql_user

## Actions

- `:create`
- `:update`
- `:drop`
- `:delete`
- `:set_password`

## Properties

| Name                   | Name? | Type            | Default | Description | Allowed Values |
| ---------------------- | ----- | --------------- | ------- | ----------- | -------------- |
| `rolename`             | ✓     | String          |         |             |                |
| `superuser`            |       | true, false     |         |             |                |
| `createdb`             |       | true, false     |         |             |                |
| `createrole`           |       | true, false     |         |             |                |
| `inherit`              |       | true, false     |         |             |                |
| `login`                |       | true, false     |         |             |                |
| `replication`          |       | true, false     |         |             |                |
| `bypassrls`            |       | true, false     |         |             |                |
| `connection_limit`     |       | Integer, String |         |             |                |
| `unencrypted_password` |       | String          |         |             |                |
| `encrypted_password`   |       | String          |         |             |                |
| `valid_until`          |       | String          |         |             |                |
| `in_role`              |       | String, Array   |         |             |                |
| `role`                 |       | String, Array   |         |             |                |
| `admin`                |       | String, Array   |         |             |                |
| `config`               |       | Hash            |         |             |                |
| `sensitive`            |       | true, false     |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Role`
