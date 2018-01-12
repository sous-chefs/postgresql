# postgresql cookbook

[![Build Status](https://travis-ci.org/sous-chefs/postgresql.svg?branch=master)](https://travis-ci.org/sous-chefs/postgresql) [![Cookbook Version](https://img.shields.io/cookbook/v/postgresql.svg)](https://supermarket.chef.io/cookbooks/postgresql)

Installs and configures PostgreSQL as a client or a server.

## Requirements

### Platforms

- Amazon Linux
- Debian 7+
- Ubuntu 14.04+
- Red Hat/CentOS/Scientific 6+
- Fedora

## PostgreSQL version

We follow the currently supported versions listed on <https://www.postgresql.org/support/versioning/>

The earliest supported version is currently:

- 9.3 (9.3.19)

### Chef

- Chef 12.14+

### Cookbooks

- `openssl`
- `build-essential`

## Deprecation notice for pg_hba.conf

Updating the pg_hba configuration can now be done with the `postgresql_access` resource which is documented below. There is a backward-compatible migration left in the `server_conf` recipe, but it will be removed in the next major release.

For each of the `node['postgresql']['pg_hba']` hashes, you want to make a corresponding postgresql_access resource like the following example:

```ruby
# What used to be this:
default['postgresql']['pg_hba'] = {
  type: 'local',
  db: 'all',
  user: 'postgres',
  addr: nil,
  method: 'ident'
}

# Is now this:
postgresql_access 'local_postgres_superuser' do
  access_type 'local'
  access_db 'all'
  access_user 'postgres'
  access_addr nil
  access_method 'ident'
end
```

**Note**: The default notification for the new `postgresql_access` resource is now `:reload` which is the recommended method of notifying PostgreSQL of access changes without requiring a full database restart. Before, the access template would defer to the notification method specified by node['postgresql']['server']['config_change_notify']

## Attributes

The following attributes are set based on the platform, see the `attributes/default.rb` file for default values.

- `node['postgresql']['version']` - version of postgresql to manage
- `node['postgresql']['dir']` - home directory of where postgresql data and configuration lives.
- `node['postgresql']['client']['packages']` - An array of package names that should be installed on "client" systems.
- `node['postgresql']['server']['packages']` - An array of package names that should be installed on "server" systems.
- `node['postgresql']['contrib']['packages']` - An array of package names that could be installed on "server" systems for useful sysadmin tools.
- `node['postgresql']['enable_pgdg_apt']` - Whether to enable the apt repo by the PostgreSQL Global Development Group, which contains newer versions of PostgreSQL.
- `node['postgresql']['enable_pgdg_yum']` - Whether to enable the yum repo by the PostgreSQL Global Development Group, which contains newer versions of PostgreSQL.
- `node['postgresql']['initdb_locale']` - Sets the default locale for the database cluster. If this attribute is not specified, the locale is inherited from the environment that initdb runs in. Sometimes you must have a system locale that is not what you want for your database cluster, and this attribute addresses that scenario. Valid only for EL-family distros (RedHat/Centos/etc.).

The following attributes are generated in `recipe[postgresql::server]`.

## Configuration

The `postgresql.conf` file is dynamically generated from attributes. Each key in `node['postgresql']['config']` is a postgresql configuration directive, and will be rendered in the config file. For example, the attribute:

```ruby
node['postgresql']['config']['listen_addresses'] = 'localhost'
```

Will result in the following line in the `postgresql.conf` file:

```ruby
listen_addresses = 'localhost'
```

The attributes file contains default values for Debian and RHEL platform families (per the `node['platform_family']`). These defaults have disparity between the platforms because they were originally extracted from the postgresql.conf files in the previous version of this cookbook, which differed in their default config. The resulting configuration files will be the same as before, but the content will be dynamically rendered from the attributes. The helpful commentary will no longer be present. You should consult the PostgreSQL documentation for specific configuration details.

For values that are "on" or "off", they should be specified as literal `true` or `false`. String values will be used with single quotes. Any configuration option set to the literal `nil` will be skipped entirely. All other values (e.g., numeric literals) will be used as is. So for example:

```ruby
node.default['postgresql']['config']['logging_collector'] = true
node.default['postgresql']['config']['datestyle'] = 'iso, mdy'
node.default['postgresql']['config']['ident_file'] = nil
node.default['postgresql']['config']['port'] = 5432
```

Will result in the following config lines:

```ruby
logging_collector = 'on'
datestyle = 'iso,mdy'
port = 5432
```

(no line printed for `ident_file` as it is `nil`)

Note that the `unix_socket_directory` configuration was renamed to `unix_socket_directories` in Postgres 9.3 so make sure to use the `node['postgresql']['unix_socket_directories']` attribute instead of `node['postgresql']['unix_socket_directory']`.

## Resources

### postgresql_extention

This resource manages postgresql extensions with a given database to ease installation/removal. It uses the name of the resource in the format `database/extension` to determine the database and extention to install.

#### Actions

- `create` - (default) Creates an extension in a given database
- `drop` - Drops an extension from the database

#### Properties

Name      | Types  | Description                                        | Default          | Required?
--------- | ------ | -------------------------------------------------- | ---------------- | ---------
database  | String | Name of the database to install the extention into | Name of resource | yes
extention | String | Name of the extention to install the database      | Name of resource | yes

#### Examples

To install the adminpack extension:

```ruby
# Add the contrib package in Ubuntu/Debian
package 'postgresql-contrib-9.6'

# Install adminpack extension
postgresql_extension 'postgres/adminpack'
```

### postgresql_access

This resource uses the accumulator pattern to build up the `pg_hba.conf` file via chef resources instead of piling on a mountain of chef attributes to make this cookbook more reusable. It directly mirrors the configuration options of the postgres hba file in the resource and by default notifies the server with a reload to avoid a full restart, causing a potential outage of service. To revoke access, simply remove the resource and the access change won't be computed into the final `pg_hba.conf`

#### Actions

- `grant` - (default) Creates an access line inside of `pg_hba.conf`

#### Properties

Name            | Types       | Description                                                                               | Default           | Required?
--------------- | ----------- | ----------------------------------------------------------------------------------------- | ----------------- | ---------
name            | String      | Name of the access resource, this is left as a comment inside the `pg_hba` config         | Resource name     | yes
source          | String      | The cookbook template filename if you want to use your own custom template                | 'pg_hba.conf.erb' | yes
cookbook        | String      | The cookbook to look in for the template source                                           | 'postgresql'      | yes
comment         | String, nil | A comment to leave above the entry in `pg_hba`                                            | nil               | no
`access_type`   | String      | The type of access, e.g. local or host                                                    | 'local'           | yes
`access_db`     | String      | The database to access. Can use 'all' for all databases                                   | 'all'             | yes
`access_user`   | String      | The user accessing the database. Can use 'all' for any user                               | 'all'             | yes
`access_addr`   | String, nil | The address(es) allowed access. Can be nil if method ident is used since it is local then | nil               | yes
`access_method` | String      | Authentication method to use                                                              | 'ident'           | yes
notification    | Symbol      | How to notify Postgres of the access change.                                              | `:reload`         | yes

#### Examples

To grant access to the postgresql user with ident authentication:

```ruby
postgresql_access 'local_postgres_superuser' do
  comment 'Local postgres superuser access'
  access_type 'local'
  access_db 'all'
  access_user 'postgres'
  access_addr nil
  access_method 'ident'
end
```

This generates the following line in the `pg_hba.conf`:

```
# Local postgres superuser access
local   all             postgres                                ident
```

**Note**: The template by default generates a local access for Unix domain sockets only to support running the SQL execute resources. In Postgres version 9.1 and higher, the method is 'peer' instead of 'ident' which is identical. It looks like this:

```
# "local" is for Unix domain socket connections only
local   all             all                                     peer
```

## Recipes

### default

Includes the client recipe.

### client

Installs the packages defined in the `node['postgresql']['client']['packages']` attribute.

### server

Install and configure postgresql for the server:

- install appropriate packages depends on OS
- generates a strong default password (via `openssl`) for `postgres` or apply postgres password from attribute
- manages the `postgresql.conf` file.
- manages the `pg_hba.conf` file.

## Usage

On systems that need to connect to a PostgreSQL database, add to a run list `recipe[postgresql]` or `recipe[postgresql::client]`.

On systems that should be PostgreSQL servers, use `recipe[postgresql::server]` on a run list. This recipe does set a password for the `postgres` user. If you're using `chef server`, if the attribute `node['postgresql']['password']['postgres']` is not found, the recipe generates a random password. If you're using `chef-solo`, you'll need to set the attribute `node['postgresql']['password']['postgres']` in your node's `json_attribs` file or in a role.

On Debian family systems, SSL will be enabled, as the packages on Debian/Ubuntu also generate the SSL certificates. If you use another platform and wish to use SSL in postgresql, then generate your SSL certificates and distribute them in your own cookbook, and set the `node['postgresql']['config']['ssl']` attribute to true in your role/cookboook/node.

On server systems, the postgres server is restarted when a configuration file changes. This can be changed to reload only by setting the following attribute:

```ruby
node['postgresql']['server']['config_change_notify'] = :reload
```

**Note**: This attribute is broken and we decide to reload service instead of restart service after a configuration change. We will try to fix to let you the choice of service action. 

## License

Copyright 2010-2017, Chef Software, Inc.

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
