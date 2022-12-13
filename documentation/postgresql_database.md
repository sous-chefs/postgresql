# postgresql_database

[Back to resource list](../README.md#resources)

This resource manages PostgreSQL databases

## Uses

- [partial/_connection](partial/_connection.md)

## Actions

- `:create` - Creates the given database
- `:update` - Updates the given database
- `:drop` - Drops the given database
- `:delete` - Alias for `:drop`

## Properties

| Name                | Name? | Type            | Default | Description                                                                                                                                                                                                                                                        | Allowed Values |
| ------------------- | ----- | --------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| `database`          | ✓     | String          |         | The name of a database to create                                                                                                                                                                                                                                   |                |
| `owner`             |       | String, Integer |         | The role name of the user who will own the new database, or DEFAULT to use the default (namely, the user executing the command). To create a database owned by another role, you must be a direct or indirect member of that role, or be a superuser.              |                |
| `template`          |       | String          |         | The name of the template from which to create the new database, or DEFAULT to use the default template (template1)                                                                                                                                                 |                |
| `encoding`          |       | Integer         |         | Character set encoding to use in the new database                                                                                                                                                                                                                  |                |
| `strategy`          |       | String          |         | Strategy to be used in creating the new database                                                                                                                                                                                                                   |                |
| `locale`            |       | String          |         | This is a shortcut for setting LC_COLLATE and LC_CTYPE at once                                                                                                                                                                                                     |                |
| `lc_collate`        |       | String          |         | Collation order (LC_COLLATE) to use in the new database. This affects the sort order applied to strings, e.g., in queries with ORDER BY, as well as the order used in indexes on text columns. The default is to use the collation order of the template database. |                |
| `lc_ctype`          |       | String          |         | Character classification (LC_CTYPE) to use in the new database. This affects the categorization of characters, e.g., lower, upper and digit. The default is to use the character classification of the template database.                                          |                |
| `icu_locale`        |       | String          |         | Specifies the ICU locale ID if the ICU locale provider is used                                                                                                                                                                                                     |                |
| `locale_provider`   |       | String          |         | Specifies the provider to use for the default collation in this database                                                                                                                                                                                           |                |
| `collation_version` |       | String          |         | Specifies the collation version string to store with the database                                                                                                                                                                                                  |                |
| `tablespace`        |       | String          |         | The name of the tablespace that will be associated with the new database                                                                                                                                                                                           |                |
| `allow_connections` |       | true, false     |         | If false then no one can connect to this database                                                                                                                                                                                                                  |                |
| `connection_limit`  |       | Integer, String |         | How many concurrent connections can be made to this database. -1 (the default) means no limit.                                                                                                                                                                     |                |
| `is_template`       |       | true, false     |         | If true, then this database can be cloned by any user with CREATEDB privileges; if false (the default), then only superusers or the owner of the database can clone it.                                                                                            |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Database`

## Examples

To create database named 'my_app' with owner 'user1':

```ruby
postgresql_database 'my_app' do
  owner 'user1'
end
```
