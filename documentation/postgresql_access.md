# postgresql_access

[Back to resource list](../README.md#resources)

This resource uses the initialised accumulator pattern to manage the `pg_hba.conf` file. It fully supports `load_current_value` and will report changes during the run and fire notifications.
The content of `pg_hba.conf` is loaded into the template variables upon the first call of the `:postgresql_access` resource, so, to remove an entry from the file the resource must be called with the `:delete` action.

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create` - Create an access entry
- `:update` - Update a pre-existing access entry
- `:delete` - Remove an access entry
- `:grant` - Alias of `:create`

## Properties

| Name           | Name? | Type         | Default | Description                          | Allowed Values |
| -------------- | ----- | ------------ | ------- | ------------------------------------ | -------------- |
| `config_file`  |       | String       |         |                                      |                |
| `source`       |       | String       |         |                                      |                |
| `type`         |       | String       |         | Access record type                   |                |
| `database`     |       | String       |         | Access record database               |                |
| `user`         |       | String       |         | Access record user                   |                |
| `address`      |       | String       |         | Access record address                |                |
| `auth_method`  |       | String       |         | Access record authentication method  |                |
| `auth_options` |       | String, Hash |         | Access record authentication options |                |
| `comment`      |       | String       |         | Access record comment                |                |

## Libraries

- `PostgreSQL::Cookbook::AccessHelpers::PgHbaTemplate`

## Examples

To grant access to the PostgreSQL user with ident authentication:

```ruby
postgresql_access `local_postgres_superuser` do
  comment `Local postgres superuser access`
  type `local`
  database `all`
  user `postgres`
  auth_method `ident`
end
```

This generates the following line in the `pg_hba.conf`:

```config
# Local postgres superuser access
local   all             postgres                                ident           # Local postgres superuser access
```
