[Back to resource list](../README.md#Resources)

# postgresql_user

This resource manage PostgreSQL users.

## Actions

- `create` - (default) Creates the given user with default or given privileges.
- `update` - Update user privileges.
- `drop` - Deletes the given user.

## Properties

| Name                 | Types   | Description                                     | Default    | Required?
| -------------------- | ------- | ----------------------------------------------- | ---------- | ---------
| `create_user`        | String  | User to create (defaults to the resource name)  |            | yes
| `superuser`          | Boolean | Define if user needs superuser role             | `false`    | no
| `createdb`           | Boolean | Define if user needs createdb role              | `false`    | no
| `createrole`         | Boolean | Define if user needs createrole role            | `false`    | no
| `inherit`            | Boolean | Define if user inherits the privileges of roles | `true`     | no
| `replication`        | Boolean | Define if user needs replication role           | `false`    | no
| `login`              | Boolean | Define if user can login                        | `true`     | no
| `password`           | String  | Set user's password                             |            | no
| `encrypted_password` | String  | Set user's password with an hashed password     |            | no
| `valid_until`        | String  | Define an account expiration date               |            | no
| `attributes`         | Hash    | Additional attributes for :update action        | `{}`       | no
| `user`               | String  | User for command                                | `postgres` | no
| `database`           | String  | Database for command                            |            | no
| `host`               | String  | Hostname for command                            |            | no
| `port`               | Integer | Port number to connect to postgres              | `5432`     | no

## Examples

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

More examples can be found in the test cookbook (`test/cookbooks/test/recipes`)

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
