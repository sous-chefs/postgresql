# postgresql_access

[Back to resource list](../README.md#resources)

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create`
- `:update`
- `:delete`
- `:grant`

## Properties

| Name           | Name? | Type         | Default | Description | Allowed Values |
| -------------- | ----- | ------------ | ------- | ----------- | -------------- |
| `config_file`  |       | String       |         |             |                |
| `source`       |       | String       |         |             |                |
| `type`         |       | String       |         |             |                |
| `database`     |       | String       |         |             |                |
| `user`         |       | String       |         |             |                |
| `address`      |       | String       |         |             |                |
| `auth_method`  |       | String       |         |             |                |
| `auth_options` |       | String, Hash |         |             |                |
| `comment`      |       | String       |         |             |                |

## Libraries

- `PostgreSQL::Cookbook::AccessHelpers::PgHbaTemplate`
