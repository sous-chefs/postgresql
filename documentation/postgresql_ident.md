# postgresql_ident

[Back to resource list](../README.md#resources)

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create`
- `:delete`

## Properties

| Name                | Name? | Type   | Default | Description | Allowed Values |
| ------------------- | ----- | ------ | ------- | ----------- | -------------- |
| `config_file`       |       | String |         |             |                |
| `source`            |       | String |         |             |                |
| `map_name`          | ✓     | String |         |             |                |
| `system_username`   |       | String |         |             |                |
| `database_username` |       | String |         |             |                |
| `comment`           |       | String |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::IdentHelpers::PgIdentTemplate`
