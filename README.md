# PostgreSQL cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/postgresql.svg)](https://supermarket.chef.io/cookbooks/postgresql)
[![Build Status](https://img.shields.io/circleci/project/github/sous-chefs/postgresql/master.svg)](https://circleci.com/gh/sous-chefs/postgresql)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Installs and configures PostgreSQL as a client or a server.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Upgrading

If you are wondering where all the recipes went in v7.0+, or how on earth I use this new cookbook please see upgrading.md for a full description.

## Requirements

### Platforms

- Amazon Linux
- Debian 7+
- Ubuntu 14.04+
- Red Hat/CentOS/Scientific 6+

### PostgreSQL version

We follow the currently supported versions listed on <https://www.postgresql.org/support/versioning/>

### Chef

- Chef 13.8+

### Cookbook Dependencies

None.

## Resources

### postgresql_client_install

This resource installs PostgreSQL client packages.

#### Actions

- `install` - (default) Install client packages

#### Properties

Name                | Types             | Description                                                   | Default                                   | Required?
------------------- | ----------------- | ------------------------------------------------------------- | ----------------------------------------- | ---------
`version`           | String            | Version of PostgreSQL to install                              | '9.6'                                     | no
`setup_repo`        | Boolean           | Define if you want to add the PostgreSQL repo                 | true                                      | no
`hba_file`          | String            |                                                               | `#{conf_dir}/main/pg_hba.conf`            | no
`ident_file`        | String            |                                                               | `#{conf_dir}/main/pg_ident.conf`          | no
`external_pid_file` | String            |                                                               | `/var/run/postgresql/#{version}-main.pid` | no
`password`          | String, nil       | Pass in a password, or have the cookbook generate one for you | random string                             | no

#### Examples

To install version 9.5:

```ruby
postgresql_client_install 'My PostgreSQL Client install' do
  version '9.5'
end
```

### postgresql_server_install

This resource installs PostgreSQL client and server packages.

#### Actions

- `install` - (default) Install client and server packages
- `create` - Initialize the database

#### Properties

Name                | Types           | Description                                   | Default                                            | Required?
------------------- | --------------- | --------------------------------------------- | -------------------------------------------------- | ---------
`version`           | String          | Version of PostgreSQL to install              | '9.6'                                              | no
`setup_repo`        | Boolean         | Define if you want to add the PostgreSQL repo | true                                               | no
`hba_file`          | String          | Path of pg_hba.conf file                      | `<default_os_path>/pg_hba.conf'`                   | no
`ident_file`        | String          | Path of pg_ident.conf file                    | `<default_os_path>/pg_ident.conf`                  | no
`external_pid_file` | String          | Path of PID file                              | `/var/run/postgresql/<version>-main.pid</version>` | no
`password`          | String, nil     | Set PostgreSQL user password                  | 'generate'                                         | no
`port`              | Integer         | Set listen port of PostgreSQL service         | 5432                                               | no
`initdb_locale`     | String          | Locale to initialise the database with        | 'C'                                                | no

#### Examples

To install PostgreSQL server, set your own postgres password using non-default service port.

```ruby
postgresql_server_install 'My PostgreSQL Server install' do
  action :install
end

postgresql_server_install 'Setup my PostgreSQL 9.6 server' do
  password 'MyP4ssw0rd'
  port 5433
  action :create
end
```

#### Known issues

On some platforms (e.g. Ubuntu 18.04), your `initdb_locale` should be set to the
same as the template database [GH-555](https://github.com/sous-chefs/postgresql/issues/555).

### postgresql_server_conf

This resource manages postgresql.conf configuration file.

#### Actions

- `modify` - (default) Manager PostgreSQL configuration file (postgresql.conf)

#### Properties

Name                   | Types   | Description                             | Default                                             | Required?
---------------------- | ------- | --------------------------------------- | --------------------------------------------------- | ---------
`version`              | String  | Version of PostgreSQL to install        | '9.6'                                               | no
`data_directory`       | String  | Path of PostgreSQL data directory       | `<default_os_data_path>`                            | no
`hba_file`             | String  | Path of pg_hba.conf file                | `<default_os_conf_path>/pg_hba.conf`                | no
`ident_file`           | String  | Path of pg_ident.conf file              | `<default_os_conf_path>/pg_ident.conf`              | no
`external_pid_file`    | String  | Path of PID file                        | `/var/run/postgresql/<postgresql_version>-main.pid` | no
`stats_temp_directory` | String  | Path of stats file                      | `/var/run/postgresql/version>-main.pg_stat_tmp`     | no
`port`                 | Integer | Set listen port of PostgreSQL service   | 5432                                                | no
`additional_config`    | Hash    | Extra configuration for the config file | {}                                                  | no

#### Examples

To setup your PostgreSQL configuration with a specific data directory. If you have installed a specific version of PostgreSQL (different from 9.6), you must specify version in this resource too.

```ruby
postgresql_server_conf 'My PostgreSQL Config' do
  version '9.5'
  data_directory '/data/postgresql/9.5/main'
  notifies :reload, 'service[postgresql]'
end
```

### postgresql_extension

This resource manages PostgreSQL extensions for a given database.

#### Actions

- `create` - (default) Creates an extension in a given database
- `drop` - Drops an extension from the database

#### Properties

Name          | Types  | Description                                                                      | Default          | Required?
------------- | ------ | -------------------------------------------------------------------------------- | ---------------- | ---------
`database`    | String | Name of the database to install the extension into                               |                  | yes
`extension`   | String | Name of the extension to install the database                                    | Name of resource | yes
`version`     | String | Version of the extension to install                                              |                  | no
`old_version` | String | Older module name for new extension replacement. Appends FROM to extension query |                  | no

#### Examples

To install the `adminpack` extension:

```ruby
# Add the contrib package in Ubuntu/Debian
package 'postgresql-contrib-9.6'

# Install adminpack extension
postgresql_extension 'postgres adminpack' do
  database 'postgres'
  extension 'adminpack'
end
```

### postgresql_access

This resource uses the accumulator pattern to build up the `pg_hba.conf` file via chef resources instead of piling on a mountain of chef attributes to make this cookbook more reusable. It directly mirrors the configuration options of the postgres hba file in the resource and by default notifies the server with a reload to avoid a full restart, causing a potential outage of service. To revoke access, simply remove the resource and the access change won't be computed into the final `pg_hba.conf`

#### Actions

- `grant` - (default) Creates an access line inside of `pg_hba.conf`

#### Properties

Name            | Types  | Description                                                                               | Default           | Required?
--------------- | ------ | ----------------------------------------------------------------------------------------- | ----------------- | ---------
`name`          | String | Name of the access resource, this is left as a comment inside the `pg_hba` config         | Resource name     | yes
`source`        | String | The cookbook template filename if you want to use your own custom template                | 'pg_hba.conf.erb' | yes
`cookbook`      | String | The cookbook to look in for the template source                                           | 'postgresql'      | yes
`comment`       | String | A comment to leave above the entry in `pg_hba`                                            | nil               | no
`access_type`   | String | The type of access, e.g. local or host                                                    | 'local'           | yes
`access_db`     | String | The database to access. Can use 'all' for all databases                                   | 'all'             | yes
`access_user`   | String | The user accessing the database. Can use 'all' for any user                               | 'all'             | yes
`access_addr`   | String | The address(es) allowed access. Can be nil if method ident is used since it is local then | nil               | no
`access_method` | String | Authentication method to use                                                              | 'ident'           | yes

#### Examples

To grant access to the PostgreSQL user with ident authentication:

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

```config
# Local postgres superuser access
local   all             postgres                                ident
```

**Note**: The template by default generates a local access for Unix domain sockets only to support running the SQL execute resources. In Postgres version 9.1 and higher, the method is 'peer' instead of 'ident' which is identical. It looks like this:

```config
# "local" is for Unix domain socket connections only
local   all             all                                     peer
```

### postgresql_ident

This resource generate `pg_ident.conf` configuration file to manage user mapping between system and PostgreSQL users.

#### Actions

- `create` - (default) Creates an mapping line inside of `pg_ident.conf`

#### Properties

Name           | Types       | Description                                                                | Default             | Required?
-------------- | ----------- | -------------------------------------------------------------------------- | ------------------- | ---------
`mapname`      | String      | Name of the user mapping                                                   | Resource name       | yes
`source`       | String      | The cookbook template filename if you want to use your own custom template | 'pg_ident.conf.erb' | no
`cookbook`     | String      | The cookbook to look in for the template source                            | 'postgresql'        | no
`comment`      | String, nil | A comment to leave above the entry in `pg_ident`                           | nil                 | no
`system_user`  | String      | System user or regexp used for the mapping                                 | None                | yes
`pg_user`      | String      | Pg user or regexp used for the mapping                                     | None                | yes

#### Examples

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

### postgresql_database

This resource manages PostgreSQL databases.

#### Actions

- `create` - (default) Creates the given database.
- `drop` - Drops the given database.

#### Properties

Name       | Types   | Description                                                         | Default             | Required?
---------- | ------- | ------------------------------------------------------------------- | ------------------- | ---------
`database` | String  | Name of the database to create                                      | Resource name       | yes
`user`     | String  | User which run psql command                                         | 'postgres'          | no
`template` | String  | Template used to create the new database                            | 'template1'         | no
`host`     | String  | Define the host server where the database creation will be executed | Not set (localhost) | no
`port`     | Integer | Define the port of PostgreSQL server                                | 5432                | no
`encoding` | String  | Define database encoding                                            | 'UTF-8'             | no
`locale`   | String  | Define database locale                                              | 'en_US.UTF-8'       | no
`owner`    | String  | Define the owner of the database                                    | Not set             | no

#### Examples

To create database named 'my_app' with owner 'user1':

```ruby
postgresql_database 'my_app' do
  owner 'user1'
end
```

#### Known issues

On some platforms (e.g. Ubuntu 18.04), your `initdb_locale` should be set to the
same as the template database [GH-555](https://github.com/sous-chefs/postgresql/issues/555).

### postgresql_user

This resource manage PostgreSQL users.

#### Actions

- `create` - (default) Creates the given user with default or given privileges.
- `update` - Update user privilieges.
- `drop` - Deletes the given user.

#### Properties

Name                 | Types   | Description                                     | Default  | Required?
-------------------- | ------- | ----------------------------------------------- | -------- | ---------
`create_user`        | String  | User to create (defaults to the resource name)  |          | Yes
`superuser`          | Boolean | Define if user needs superuser role             | false    | no
`createdb`           | Boolean | Define if user needs createdb role              | false    | no
`createrole`         | Boolean | Define if user needs createrole role            | false    | no
`inherit`            | Boolean | Define if user inherits the privileges of roles | true     | no
`replication`        | Boolean | Define if user needs replication role           | false    | no
`login`              | Boolean | Define if user can login                        | true     | no
`password`           | String  | Set user's password                             |          | no
`encrypted_password` | String  | Set user's password with an hashed password     |          | no
`valid_until`        | String  | Define an account expiration date               |          | no
`attributes`         | Hash    | Additional attributes for :update action        | {}       | no
`user`               | String  | User for command                                | postgres | no
`database`           | String  | Database for command                            |          | no
`host`               | String  | Hostname for command                            |          | no
`port`               | Integer | Port number to connect to postgres              | 5432     | no

#### Examples

Create a user `user1` with a password, with `createdb` role and set an expiration date to 2018, Dec 21.

```ruby
postgresql_user 'user1' do
  password 'UserP4ssword'
  createdb true
  valid_until '2018-12-31'
end
```

Create a user `user1` with a password, with `createdb` role and set an expiration date to 2018, Dec 21.

```ruby
postgresql_user 'user1' do
  password 'UserP4ssword'
  createdb true
  valid_until '2018-12-31'
end
```

## Usage

To install and configure your PostgreSQL instance you need to create your own cookbook and call needed resources with your own parameters.

More examples can be found in `test/cookbooks/test/recipes`

## Example Usage

```ruby
# cookbooks/my_postgresql/recipes/default.rb

postgresql_client_install 'PostgreSQL Client' do
  setup_repo false
  version '10.6'
end

postgresql_server_install 'PostgreSQL Server' do
  version '10.6'
  setup_repo false
  password 'P0stgresP4ssword'
end

postgresql_server_conf 'PostgreSQL Config' do
  notifies :reload, 'service[postgresql]'
end
```

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
