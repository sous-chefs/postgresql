# postgresql_ident

[Back to resource list](../README.md#resources)

This resource generate `pg_ident.conf` configuration file to manage user mapping between system and PostgreSQL users.

## Uses

- [partial/_config_file](partial/_config_file.md)

## Actions

- `:create` - Creates a mapping line inside of `pg_ident.conf`
- `:update` - Update a mapping line inside of `pg_ident.conf`
- `:delete` - Delete a mapping line inside of `pg_ident.conf`

## Properties

| Name                | Name? | Type   | Default | Description                                                              | Allowed Values |
| ------------------- | ----- | ------ | ------- | ------------------------------------------------------------------------ | -------------- |
| `config_file`       |       | String |         |                                                                          |                |
| `source`            |       | String |         |                                                                          |                |
| `map_name`          | ✓     | String |         | Arbitrary name that will be used to refer to this mapping in pg_hba.conf |                |
| `system_username`   |       | String |         | Operating system user name                                               |                |
| `database_username` |       | String |         | Database user name                                                       |                |
| `comment`           |       | String |         | Ident mapping record comment                                             |                |

## Libraries

- `PostgreSQL::Cookbook::IdentHelpers::PgIdentTemplate`

## Examples

Creates a `mymapping` mapping that map `john` system user to `user1` PostgreSQL user:

```ruby
postgresql_ident 'Map john to user1' do
  comment 'John Mapping'
  map_name 'mymapping'
  system_username 'john'
  database_username 'user1'
end
```

This generates the following line in the `pg_ident.conf`:

```config
# MAPNAME       SYSTEM-USERNAME         PG-USERNAME

# John Mapping
mymapping       john                    user1               # John Mapping
```

To grant access to the foo user with password authentication:

```ruby
postgresql_access 'local_foo_user' do
  comment 'Foo user access'
  type 'host'
  database 'all'
  user 'foo'
  address '127.0.0.1/32'
  auth_method 'md5'
end
```

This generates the following line in the `pg_hba.conf`:

```config
# Local postgres superuser access
host   all             foo               127.0.0.1/32           ident           # Foo user access
```
