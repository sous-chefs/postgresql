# postgresql_role

[Back to resource list](../README.md#resources)

## Uses

- [partial/_connection](partial/_connection.md)

## Provides

- :postgresql_role

## Actions

- `:create`
- `:update`
- `:drop`
- `:delete`
- `:set_password`

## Properties

| Name                   | Name? | Type            | Default | Description                                                                                                                                  | Allowed Values |
| ---------------------- | ----- | --------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `sensitive`            |       | true, false     |         |                                                                                                                                              |                |
| `rolename`             | ✓     | String          |         | The name of the new role                                                                                                                     |                |
| `superuser`            |       | true, false     |         | Determine whether the new role is a "superuser" who can override all access restrictions within the database                                 |                |
| `createdb`             |       | true, false     |         | Define a role's ability to create databases                                                                                                  |                |
| `createrole`           |       | true, false     |         | Determine whether a role will be permitted to create new roles (that is, execute CREATE ROLE)                                                |                |
| `inherit`              |       | true, false     |         | Determine whether a role "inherits" the privileges of roles it is a member of                                                                |                |
| `login`                |       | true, false     |         | Determine whether a role is allowed to log in                                                                                                |                |
| `replication`          |       | true, false     |         | Determine whether a role is a replication role                                                                                               |                |
| `bypassrls`            |       | true, false     |         | Determine whether a role bypasses every row-level security (RLS) policy                                                                      |                |
| `connection_limit`     |       | Integer, String |         | If role can log in, this specifies how many concurrent connections the role can make                                                         |                |
| `unencrypted_password` |       | String          |         | Sets the role password via a plain text string                                                                                               |                |
| `encrypted_password`   |       | String          |         | Sets the role password via a pre-encrypted string                                                                                            |                |
| `valid_until`          |       | String          |         | Sets a date and time after which the role password is no longer valid                                                                        |                |
| `in_role`              |       | String, Array   |         | Lists one or more existing roles to which the new role will be immediately added as a new membe                                              |                |
| `role`                 |       | String, Array   |         | Lists one or more existing roles which are automatically added as members of the new role                                                    |                |
| `admin`                |       | String, Array   |         | Like ROLE, but the named roles are added to the new role WITH ADMIN OPTION, giving them the right to grant membership in this role to others |                |
| `config`               |       | Hash            |         | Role config values as a Hash                                                                                                                 |                |

## Libraries

- `PostgreSQL::Cookbook::SqlHelpers::Role`

## Examples

Create a user `user1` with a password, with `createdb` and set an expiration date to 2018, Dec 21.

```ruby
postgresql_role 'user1' do
  unencrypted_password 'UserP4ssword'
  createdb true
  valid_until '2018-12-31'
end
```

Create a user `user1` with a password, with `createdb` and set an expiration date to 2018, Dec 21.

```ruby
postgresql_role 'user1' do
  unencrypted_password 'UserP4ssword'
  createdb true
  valid_until '2018-12-31'
end
```
