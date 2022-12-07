# postgresql_extension

[Back to resource list](../README.md#resources)

## Uses

- [partial/_connection](partial/_connection.md)

## Actions

- `:create`
- `:drop`
- `:delete`

## Properties

| Name          | Name? | Type        | Default | Description | Allowed Values |
| ------------- | ----- | ----------- | ------- | ----------- | -------------- |
| `extension`   | ✓     | String      |         |             |                |
| `schema`      |       | String      |         |             |                |
| `old_version` |       | String      |         |             |                |
| `version`     |       | String      |         |             |                |
| `cascade`     |       | true, false |         |             |                |
| `restrict`    |       | true, false |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Extension`
