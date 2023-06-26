# postgresql_extension

[Back to resource list](../README.md#resources)

This resource manages PostgreSQL extensions for a given database

## Uses

- [partial/_connection](partial/_connection.md)

## Actions

- `:create` - Creates an extension in a given database
- `:drop` - Drops an extension from the database
- `:delete` - Alias for `:drop`

## Properties

| Name          | Name? | Type        | Default | Description                                                                                                                                                                                            | Allowed Values |
| ------------- | ----- | ----------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| `extension`   | ✓     | String      |         | The name of the extension to be installed                                                                                                                                                              |                |
| `schema`      |       | String      |         | The name of the schema in which to install the extension objects                                                                                                                                       |                |
| `old_version` |       | String      |         | old_version must be specified when, and only when, you are attempting to install an extension that replaces an "old style" module that is just a collection of objects not packaged into an extension. |                |
| `version`     |       | String      |         | The version of the extension to install                                                                                                                                                                |                |
| `cascade`     |       | true, false |         | Automatically install any extensions that this extension depends on that are not already installed                                                                                                     |                |
| `restrict`    |       | true, false |         | This option prevents the specified extensions from being dropped if other objects, besides these extensions, their members, and their explicitly dependent routines, depend on them                    |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Extension`

## Examples

To install the `adminpack` extension:

```ruby
# Add the contrib package in Ubuntu/Debian
package 'postgresql-contrib15'

# Install adminpack extension
postgresql_extension 'postgres adminpack' do
  dbname 'postgres'
  extension 'adminpack'
end
```
