# Upgrading from v6.0

From v7.0.0 of the postgresql cookbook we have removed all recipes and attributes from the cookbook.

## Deprecations

### Gem

Due to limitations in the gem compile process (libssl related) we have removed the pg_gem.

We no longer support accessing the database via the gem, and internally use the cli.

### PG Tune

We currently do not implement the PG Tune functionality.

This may be added in a future release.

## Major Changes

Recipes are no longer supported so you should take a look at the examples in `test/cookbooks/test/recipes`

An example of how to

- Install the the server from the postgresql repository
- Install a database
- Install an extension

install an extension

```ruby
postgresql_repository 'install'

postgresql_server_install 'package'

postgresql_database 'test_1'

postgresql_extension 'openfts' do
  database 'test_1'
end
```
