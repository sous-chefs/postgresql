[Back to resource list](../README.md#Resources)

# postgresql_access

This resource uses the accumulator pattern to build up the `pg_hba.conf` file to make this cookbook more reusable. It directly mirrors the configuration options of the Postgres hba file in the resource and by default notifies the server with a reload to avoid a full restart (and potential outage of service). To revoke access, simply remove the resource and the access change won't be present in the final `pg_hba.conf` on subsequent Chef runs.

## Actions

- `grant` - (default) Creates an access line inside of `pg_hba.conf`

## Properties

| Name            | Types  | Description                                                                               | Default           | Required? |
| --------------- | ------ | ----------------------------------------------------------------------------------------- | ----------------- | --------- |
| `name`          | String | Name of the access resource, this is left as a comment inside the `pg_hba` config         | Resource name     | yes       |
| `source`        | String | The cookbook template filename if using a custom template                                 | `pg_hba.conf.erb` | yes       |
| `cookbook`      | String | The cookbook to look in for the template source                                           | `postgresql`      | yes       |
| `comment`       | String | A comment to leave above the entry in `pg_hba`                                            |                   | no        |
| `access_type`   | String | The type of access, e.g. local or host                                                    | `local`           | yes       |
| `access_db`     | String | The database to access. Can use `all` for all databases                                   | `all`             | yes       |
| `access_user`   | String | The user accessing the database. Can use `all` for any user                               | `all`             | yes       |
| `access_addr`   | String | The address(es) allowed access. Not needed if method ident is used since it is local then |                   | no        |
| `access_method` | String | Authentication method to use                                                              | `ident`           | yes       |

## Examples

To grant access to the PostgreSQL user with ident authentication:

```ruby
postgresql_access `local_postgres_superuser` do
  comment `Local postgres superuser access`
  access_type `local`
  access_db `all`
  access_user `postgres`
  access_method `ident`
end
```

This generates the following line in the `pg_hba.conf`:

```config
# Local postgres superuser access
local   all             postgres                                ident
```

**Note**: The template by default generates a local access for Unix domain sockets only to support running the SQL execute resources. In Postgres version 9.1 and higher, the method is `peer` instead of `ident` which is identical. It looks like this:

```config
# "local" is for Unix domain socket connections only
local   all             all                                     peer
```
