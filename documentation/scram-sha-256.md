# SCRAM-SHA-256 Authentication

SCRAM-SHA-256 (Salted Challenge Response Authentication Mechanism) is a password authentication method in PostgreSQL that provides better security than traditional MD5 authentication.

## Overview

SCRAM-SHA-256 authentication offers several advantages:
- **Stronger security**: Uses SHA-256 instead of MD5
- **Salt protection**: Prevents rainbow table attacks
- **Iteration count**: Makes brute force attacks more difficult
- **Mutual authentication**: Both client and server verify each other

## Password Format

SCRAM-SHA-256 passwords have this specific format:
```
SCRAM-SHA-256$<iteration_count>:<salt>$<StoredKey>:<ServerKey>
```

Example:
```
SCRAM-SHA-256$4096:27klCUc487uwvJVGKI5YNA==$6K2Y+S3YBlpfRNrLROoO2ulWmnrQoRlGI1GqpNRq0T0=:y4esBVjK/hMtxDB5aWN4ynS1SnQcT1TFTqV0J/snls4=
```

## Usage with Chef

### Creating Users with SCRAM-SHA-256 Passwords

When you have a pre-computed SCRAM-SHA-256 password hash:

```ruby
postgresql_role 'secure_user' do
  encrypted_password 'SCRAM-SHA-256$4096:27klCUc487uwvJVGKI5YNA==$6K2Y+S3YBlpfRNrLROoO2ulWmnrQoRlGI1GqpNRq0T0=:y4esBVjK/hMtxDB5aWN4ynS1SnQcT1TFTqV0J/snls4='
  login true
  action :create
end
```

### Automatic Character Escaping

The cookbook automatically handles escaping of special characters (`$`) in SCRAM-SHA-256 passwords. You don't need to manually escape these characters - the cookbook will handle this transparently.

**Before (manual escaping required):**
```ruby
postgresql_role 'user1' do
  # Manual escaping was required
  password 'SCRAM-SHA-256$4096:salt$key:server'.gsub('$', '\$')
  action [:create, :update]
end
```

**Now (automatic escaping):**
```ruby
postgresql_role 'user1' do
  # No manual escaping needed
  encrypted_password 'SCRAM-SHA-256$4096:salt$key:server'
  action [:create, :update]
end
```

## Configuring Authentication

To use SCRAM-SHA-256 authentication, configure the access method:

```ruby
postgresql_access 'scram authentication' do
  type 'host'
  database 'all'
  user 'myuser'
  address '127.0.0.1/32'
  auth_method 'scram-sha-256'
end
```

## Password Generation

### Using PostgreSQL

Generate a SCRAM-SHA-256 password directly in PostgreSQL:

```sql
-- Set password for existing user (PostgreSQL will hash it)
ALTER ROLE myuser PASSWORD 'plaintext_password';

-- Check the generated hash
SELECT rolpassword FROM pg_authid WHERE rolname = 'myuser';
```

### Using Ruby

Generate a SCRAM-SHA-256 hash using the `scram-sha-256` gem:

```ruby
require 'scram-sha-256'

# Generate hash with default iteration count (4096)
password_hash = ScramSha256.hash_password('my_plain_password')

# Generate hash with custom iteration count
password_hash = ScramSha256.hash_password('my_plain_password', 8192)
```

### Using Python

Generate a SCRAM-SHA-256 hash using Python:

```python
import hashlib
import hmac
import base64
import secrets

def generate_scram_sha256(password, salt=None, iterations=4096):
    if salt is None:
        salt = secrets.token_bytes(16)
    
    # Implementation details would go here
    # This is a simplified example
    pass
```

## Common Use Cases

### Control Panel Integration

When integrating with control panels that pre-hash passwords:

```ruby
# Control panel provides pre-hashed password
hashed_password = control_panel.get_user_password_hash(username)

postgresql_role username do
  encrypted_password hashed_password
  login true
  createdb user_permissions.include?('createdb')
  action [:create, :update]
end
```

### Migration from MD5

When migrating from MD5 to SCRAM-SHA-256:

```ruby
# First, configure SCRAM-SHA-256 authentication
postgresql_access 'upgrade to scram' do
  type 'host'
  database 'all'
  user 'all'
  address '127.0.0.1/32'
  auth_method 'scram-sha-256'
end

# Users will need to reset their passwords
# The new passwords will automatically use SCRAM-SHA-256
```

## Troubleshooting

### Common Issues

1. **Password mangling**: If you see passwords with missing `$` characters, ensure you're using this cookbook version that includes automatic escaping.

2. **Authentication failures**: Verify that:
   - The `pg_hba.conf` is configured for `scram-sha-256`
   - The password hash format is correct
   - The user has login privileges

3. **Iteration count**: Higher iteration counts (e.g., 8192 or 16384) provide better security but require more CPU time.

### Debugging

Check the PostgreSQL logs for authentication details:

```bash
tail -f /var/log/postgresql/postgresql-*.log
```

Verify user configuration:

```sql
SELECT rolname, rolcanlogin, rolpassword 
FROM pg_authid 
WHERE rolname = 'your_username';
```

## Security Recommendations

1. **Use high iteration counts**: 4096 is the minimum; consider 8192 or higher for sensitive applications.
2. **Enforce SCRAM-SHA-256**: Disable MD5 authentication entirely when possible.
3. **Regular password rotation**: Implement password rotation policies.
4. **Monitor authentication**: Log and monitor authentication attempts.

## References

- [PostgreSQL SCRAM-SHA-256 Documentation](https://www.postgresql.org/docs/current/auth-password.html)
- [RFC 7677: SCRAM-SHA-256 and SCRAM-SHA-256-PLUS](https://tools.ietf.org/html/rfc7677)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/auth-methods.html)