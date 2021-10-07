[Back to resource list](../README.md#Resources)

# postgresql_extension

This resource manages PostgreSQL extensions for a given database.

## Actions

- `create` - (default) Creates an extension in a given database
- `drop` - Drops an extension from the database

## Properties

| Name          | Types  | Description                                                                      | Default       | Required? |
| ------------- | ------ | -------------------------------------------------------------------------------- | ------------- | --------- |
| `database`    | String | Name of the database to install the extension into                               |               | yes       |
| `extension`   | String | Name of the extension to install the database                                    | Resource name | yes       |
| `version`     | String | Version of the extension to install                                              |               | no        |
| `old_version` | String | Older module name for new extension replacement. Appends FROM to extension query |               | no        |

## Examples

To install the `adminpack` extension:

```ruby
# Add the contrib package in Ubuntu/Debian
package 'postgresql-contrib12'

# Install adminpack extension
postgresql_extension 'postgres adminpack' do
  database 'postgres'
  extension 'adminpack'
end
```
