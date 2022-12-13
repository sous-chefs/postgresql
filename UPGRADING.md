# Upgrading

## Upgrading to v11.0

Version 11 is a major refactor and will require wrapping cookbooks to be updated to match the resource changes.

### Summary

- All resources now provide `load_current_value` support so will report changes on converge and will fire notifications.
  - To provide this, all database access has been switched back to using the `pg` gem
- The `:client_install`, `:server_install` and `:repository` resources have been condensed into a single `:install` resource providing the same install functionality
- Service actions have been removed from the install resource
- The `:server_conf` resource have been renamed to `:config` and server configuration is expected to be passed as a Hash to the `:server_config` property
  - This change has been made to support later PostgreSQL version where some configuration values may have been removed
- A `:service` resource is provided to manage PostgreSQL service management
- Various resource properties have been renamed to remove collisions and match the PostgreSQL documentation and system column names
- The `:access` and `:ident` resources now use a persistent accumulator so removals require an explicit `:delete` action

## Upgrading from v6.0

From v7.0.0 of the postgresql cookbook we have removed all recipes and attributes from the cookbook.

### Deprecations

#### Gem

Due to limitations in the gem compile process (libssl related) we have removed the pg_gem.

We no longer support accessing the database via the gem, and internally use the cli.

#### PG Tune

We currently do not implement the PG Tune functionality.

This may be added in a future release.

### Major Changes

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
