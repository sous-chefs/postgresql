# postgresql_database

[Back to resource list](../README.md#resources)

## Uses

- [partial/_connection](partial/_connection.md)

## Actions

- `:create`
- `:update`
- `:drop`
- `:delete`

## Properties

| Name                | Name? | Type            | Default | Description | Allowed Values |
| ------------------- | ----- | --------------- | ------- | ----------- | -------------- |
| `database`          | ✓     | String          |         |             |                |
| `owner`             |       | String, Integer |         |             |                |
| `template`          |       | String          |         |             |                |
| `encoding`          |       | Integer         |         |             |                |
| `strategy`          |       | String          |         |             |                |
| `locale`            |       | String          |         |             |                |
| `lc_collate`        |       | String          |         |             |                |
| `lc_ctype`          |       | String          |         |             |                |
| `icu_locale`        |       | String          |         |             |                |
| `locale_provider`   |       | String          |         |             |                |
| `collation_version` |       | String          |         |             |                |
| `tablespace`        |       | String          |         |             |                |
| `allow_connections` |       | true, false     |         |             |                |
| `connection_limit`  |       | Integer, String |         |             |                |
| `is_template`       |       | true, false     |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Database`
