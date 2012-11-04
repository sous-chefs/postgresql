Description
===========

Installs and configures PostgreSQL as a client or a server.

Requirements
============

## Platforms

* Debian, Ubuntu
* Red Hat/CentOS/Scientific (6.0+ required) - "EL6-family"
* Fedora
* SUSE

Tested on:

* Ubuntu 10.04, 11.10, 12.04
* Red Hat 6.1, Scientific 6.1, CentOS 6.3

## Cookboooks

Requires Opscode's `openssl` cookbook for secure password generation.

Requires a C compiler and development headers in order to build the
`pg` RubyGem to provide Ruby bindings in the `ruby` recipe.

Opscode's `build-essential` cookbook provides this functionality on
Debian, Ubuntu, and EL6-family.

While not required, Opscode's `database` cookbook contains resources
and providers that can interact with a PostgreSQL database. This
cookbook is a dependency of database.

Attributes
==========

The following attributes are set based on the platform, see the
`attributes/default.rb` file for default values.

* `node['postgresql']['version']` - version of postgresql to manage

* `node['postgresql']['data_dir']` - where postgresql data lives

* `node['postgresql']['conf_dir']` - where postgresql configuration lives

* `node['postgresql']['client']['packages']` - An array of package names
  that should be installed on "client" systems.

* `node['postgresql']['server']['packages']` - An array of package names
  that should be installed on "server" systems.

## Network Settings

* `node['postgresql'['listen_addresses']` - Local network addresses to listen
  on. Defaults to 'localhost'

* `node['postgresql']['port']` - The port postgres should listen on. Must be a
  non-privileged port (_i.e._ >1024). Defaults to 5432.

* `node['postgresql']['max_connections']` - The maximum number of concurrent
  connections. Defaults to 100.

* `node['postgresql']['unix_socket_directory']` - The directory in which the unix
  socket for unix domain connections should be created. Defaults to
  `/var/run/postgresql`.

## SSL Configuration

* `node['postgresql']['ssl']` - whether to enable SSL. Defaults to off. For
  Ubuntu, you can turn it on, and postgres will use the "Snake Oil" certificate
  from the OpenSSL distro, so you can at least get up and running and replace
  the certificate in a later cookbook. On CentOS, you'll need to figure out how
  to get the certificate in place before running this recipe. The certificate,
  including the entire signing chain, must be placed in
  `"#{node['postgresql']['data_dir']/server.crt"` and the key must be in
  `"#{node['postgresql']['data_dir']/server.key"` and must not have a
  passphrase. Both files must be readable by the postgres user, and the key
  should be readable to _only_ the postgres user.

* `node['postgresql']['ssl_renegotiation_limit']` - the limit on the amount of
  data can be transferred in an SSL session before it is renegotiated and new
  keys are exchanged. Session renegotiation reduces the risk of cryptanalysis on
  the channel at the cost of performance. Defaults to 512MB.

  **Note:** 

  Some SSL libraries shipped prior to November 2009 are insecure when using SSL
  renegotiation due to a vulnerability in the protocol. In response to the
  vulnerability, some vendors shipped SSL libraries incapable of renegotiation
  as a stop-gap measure. If using either a vulnerable or crippled library, SSL
  renegotiation should be disabled.

* `node['postgresql']['ssl_ciphers']` - An OpenSSL-style [cipher list](http://www.openssl.org/docs/apps/ciphers.html)
  of allowed SSL ciphers.  Defaults to `!aNULL:!eNULL:!LOW:!EXPORT:!MD5:ALL`

## Resource Tuning

A number of attributes have been exposed for tuning the postgres installation.
The three most important are:

*  `node['postgresql']['total_memory_percentage']` - The percentage of the node's total
   available memory that should be dedicated to postgresql. Defaults to 0.80
   (80%)

*  `node['postgresql']['shared_memory_percentage']` - The percentage of its
   memory that postgresql should dedicate to shared buffers. Defaults to 0.25
   (25%)

*  `node['postgresql']['effective_cache_size_percentage']` - The percentage of
   postgresql's total memory percentage that the query optimizer should assume
   is available for caching. Defaults to 0.80 (80%)

These three percentages will be used to calculate the values of several memory
related tunable parameters in the postgresql.conf file. These will be recorded
to the node as well (and can be hand-tuned to override the default
calculations):

* `node['postgresql']['total_memory_mb']` - The total memory, in mebibytes,
  allocated to postgresql.

* `node['postgresql']['shared_buffers']` - The value of the postgresql.conf
  `shared_buffers` parameter.

* `node['postgresql']['effective_cache_size']` - The value of the postgresql.conf
  `effective_cache_size` parameter.

The following tunable parameters are _not_ calculated, as there is no good
general rule of thumb; they are highly dependent on the server work load.

* `node['postgresql']['work_mem']` - Specifies the amount of memory to be used
  by internal sort operations and hash tables before writing to temporary disk
  files. The value defaults to 32 MB. Note that for a complex query, several sort
  or hash operations might be running in parallel; each operation will be
  allowed to use as much memory as this value specifies before it starts to
  write data into temporary files. Also, several running sessions could be doing
  such operations concurrently. Therefore, the total memory used could be many
  times the value of work_mem; it is necessary to keep this fact in mind when
  choosing the value. Sort operations are used for ORDER BY, DISTINCT, and merge
  joins. Hash tables are used in hash joins, hash-based aggregation, and
  hash-based processing of IN subqueries.

* `node['postgresql']['maintenance_work_mem']` - Specifies the maximum amount of
  memory to be used by maintenance operations, such as VACUUM, CREATE INDEX, and
  ALTER TABLE ADD FOREIGN KEY. It defaults to 16 megabytes (16MB). Since only
  one of these operations can be executed at a time by a database session, and
  an installation normally doesn't have many of them running concurrently, it's
  safe to set this value significantly larger than work_mem. Larger settings
  might improve performance for vacuuming and for restoring database dumps.
  Note that when autovacuum runs, up to autovacuum_max_workers times this memory
  may be allocated, so be careful not to set the default value too high.

## Logging

* `node['postgresql']['log_destination']` - The destination for log messages
  must be one of `stderr`, `csvlog`, or `syslog`. May also be a comma separated
  listing containing multiple of those (_e.g._ `stderr,csvlog`). Defaults to
  `csvlog`

* `node['postgresql']['logging_collector']` - This parameter captures plain and
  CSV-format log messages sent to stderr and redirects them into log files. This
  approach is often more useful than logging to syslog, since some types of
  messages might not appear in syslog output (a common example is dynamic-linker
  failure messages). Defaults to `on`. Required to be `on` if using the csvlog
  destination.

* `node['postgresql']['log_directory']` - The directory where log files should
  be saved. Defaults to `/var/log/postgresql`

* `node['postgresql']['log_filename']` - The pattern to use when generating log
  file names. Defaults to `postgresql-%Y-%m-%d_%H%M%S`

* `node['postgresql']['log_file_mode']` - The permissions to set on the log
  file. Defaults to '640'.

* `node['postgresql']['log_rotation_age']` - When logging_collector is enabled,
  this parameter determines the maximum lifetime of an individual log file.
  After this many minutes have elapsed, a new log file will be created. Set to
  zero to disable time-based creation of new log files. Defaults to `1d` (one
  day).

* `node['postgresql']['log_rotation_size']` - When logging_collector is enabled,
  this parameter determines the maximum size of an individual log file. When
  this limit is exceeded, a new log file will be created. Set to zero to disable
  size-based creation of new log files. Defaults to `100MB` (100 megabytes).

* `node['postgresql']['log_min_messages']` - Controls which message levels are
  written to the server log. Valid values are DEBUG5, DEBUG4, DEBUG3, DEBUG2,
  DEBUG1, INFO, NOTICE, WARNING, ERROR, LOG, FATAL, and PANIC. Each level
  includes all the levels that follow it. The later the level, the fewer
  messages are sent to the log. The default is WARNING.

* `node['postgresql']['log_min_error_statement']` - Controls which SQL
  statements that cause an error condition are recorded in the server log. The
  current SQL statement is included in the log entry for any message of the
  specified severity or higher. Valid values are DEBUG5, DEBUG4, DEBUG3, DEBUG2,
  DEBUG1, INFO, NOTICE, WARNING, ERROR, LOG, FATAL, and PANIC. The default is
  ERROR, which means statements causing errors, log messages, fatal errors, or
  panics will be logged. To effectively turn off logging of failing statements,
  set this parameter to PANIC.

* `node['postgresql']['log_min_duration_statement']` - Causes the duration of
  each completed statement to be logged if the statement ran for at least the
  specified number of milliseconds. Setting this to zero prints all statement
  durations. Minus-one (the default) disables logging statement durations. For
  example, if you set it to 250ms then all SQL statements that run 250ms or
  longer will be logged. Enabling this parameter can be helpful in tracking down
  unoptimized queries in your applications. Defaults to `-1`, disabling slow
  statement logging.

## Replication

### Replication Masters
* `node['postgresql']['max_wal_senders']` - Specifies the maximum number of
  concurrent connections from standby servers or streaming base backup clients
  (i.e., the maximum number of simultaneously running WAL sender processes). The
  default is zero, meaning replication is disabled. WAL sender processes count
  towards the total number of connections, so the parameter cannot be set higher
  than max_connections

* `default['postgresql']['wal_keep_segments'] - Specifies the minimum number of
  past log file segments kept in the pg_xlog directory, in case a standby server
  needs to fetch them for streaming replication. Each segment is normally 16
  megabytes. If a standby server connected to the primary falls behind by more
  than wal_keep_segments segments, the primary might remove a WAL segment still
  needed by the standby, in which case the replication connection will be
  terminated. (However, the standby server can recover by fetching the segment
  from archive, if WAL archiving is in use.) Defaults to 0.

### Replication Slaves

* `node['postgresql']['hot_standby']` - Specifies whether or not you can connect
  and run queries during recovery. Defaults to 'off'
 
## Other attributes

The following attribute is generated in `recipe[postgresql::server]`.

* `node['postgresql']['password']['postgres']` - randomly generated
  password by the `openssl` cookbook's library.

Recipes
=======

default
-------

Includes the client recipe.

client
------

Installs postgresql client packages and development headers during the
compile phase. Also installs the `pg` Ruby gem during the compile
phase so it can be made available for the `database` cookbook's
resources, providers and libraries.

ruby
----

**NOTE** This recipe may not currently work when installing Chef with
  the
  ["Omnibus" full stack installer](http://opscode.com/chef/install) on
  some platforms due to an incompatibility with OpenSSL. See
  [COOK-1406](http://tickets.opscode.com/browse/COOK-1406)

Install the `pg` gem under Chef's Ruby environment so it can be used
in other recipes.

server
------

Includes the `server_debian` or `server_redhat` recipe to get the
appropriate server packages installed and service managed. Also
manages the configuration for the server:

* generates a strong default password (via `openssl`) for `postgres`
* sets the password for postgres
* manages the `pg_hba.conf` file.

server\_debian
--------------

Installs the postgresql server packages, manages the postgresql
service and the postgresql.conf file.

server\_redhat
--------------

Manages the postgres user and group (with UID/GID 26, per RHEL package
conventions), installs the postgresql server packages, initializes the
database and manages the postgresql service, and manages the
postgresql.conf file.

sysctl
------

Applies several linux kernel tuning parameters using the `sysctl::default`
recipe from the `sysctl` community cookbook. The parameter setting is generally
conservative; if it detects a setting that is "better" (_e.g._ a larger setting
for `kernel.shmmax` will not be replaced). The recipe can detect the current
settings in a couple different ways. First, it will look for existing `sysctl`
entries on the node. Additionally, if the Cloudant [sysctl Ohai
plugin](https://github.com/cloudant/ohai-plugins/tree/master/sysctl.rb) is run
on the node, the current sysctl settings will be checked. Finally, if none of
these are available, some hardcoded defaults based on inspecting a freshly
installed Ubuntu system will be used as the baseline. The details for
calculating the sysctl tweaks can be found in the
`libraries/sysctl_tweak_calculator.rb` file.

**Note**

As of version 0.1.0 of the sysctl cookbok, this recipe will only work on Debian
and Ubuntu systems, as that cookbook only supports those systems.

Resources/Providers
===================

See the [database](http://community.opscode.com/cookbooks/database)
for resources and providers that can be used for managing PostgreSQL
users and databases.

Usage
=====

On systems that need to connect to a PostgreSQL database, add to a run
list `recipe[postgresql]` or `recipe[postgresql::client]`.

On systems that should be PostgreSQL servers, use
`recipe[postgresql::server]` on a run list. This recipe does set a
password and expect to use it. It performs a node.save when Chef is
not running in `solo` mode. If you're using `chef-solo`, you'll need
to set the attribute `node['postgresql']['password']['postgres']` in
your node's `json_attribs` file or in a role.

If you override the configuration defaults, you may need to change system
settings with sysctl (for example kernel.shmmax and fs.file-max) before
running `recipe[postgresql::server]`.

License and Author
==================

Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Lamont Granquist (<lamont@opscode.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
