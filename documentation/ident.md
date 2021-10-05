[Back to resource list](../README.md#Resources)

# postgresql_ident

This resource generate `pg_ident.conf` configuration file to manage user mapping between system and PostgreSQL users.

## Actions

- `create` - (default) Creates an mapping line inside of `pg_ident.conf`

## Properties

| Name          | Types       | Description                                                                | Default               | Required? |
| ------------- | ----------- | -------------------------------------------------------------------------- | --------------------- | --------- |
| `mapname`     | String      | Name of the user mapping                                                   | Resource name         | yes       |
| `source`      | String      | The cookbook template filename if you want to use your own custom template | `'pg_ident.conf.erb'` | no        |
| `cookbook`    | String      | The cookbook to look in for the template source                            | `'postgresql'`        | no        |
| `comment`     | String, nil | A comment to leave above the entry in `pg_ident`                           |                       | no        |
| `system_user` | String      | System user or regexp used for the mapping                                 |                       | yes       |
| `pg_user`     | String      | Pg user or regexp used for the mapping                                     |                       | yes       |

## Examples

Creates a `mymapping` mapping that map `john` system user to `user1` PostgreSQL user:

```ruby
postgresql_ident 'Map john to user1' do
  comment 'John Mapping'
  mapname 'mymapping'
  system_user 'john'
  pg_user 'user1'
end
```

This generates the following line in the `pg_ident.conf`:

```config
# MAPNAME       SYSTEM-USERNAME         PG-USERNAME

# John Mapping
mymapping       john                    user1
```

To grant access to the foo user with password authentication:

```ruby
postgresql_access 'local_foo_user' do
  comment 'Foo user access'
  access_type 'host'
  access_db 'all'
  access_user 'foo'
  access_addr '127.0.0.1/32'
  access_method 'md5'
end
```

This generates the following line in the `pg_hba.conf`:

```config
# Local postgres superuser access
host   all             foo               127.0.0.1/32           ident
```
