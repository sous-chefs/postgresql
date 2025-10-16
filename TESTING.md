# Testing

Please refer to [the community cookbook documentation on testing](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/main/TESTING.MD).

## Quick Start for Local Testing

### Prerequisites

- **Chef Workstation**: Install from [Chef Downloads](https://www.chef.io/downloads/tools/workstation)
- **Docker**: Required for Dokken driver (faster local testing)
  - macOS: [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: Install via package manager

### Setup

1. **Enable Dokken driver** (faster than Vagrant):

   ```bash
   export KITCHEN_LOCAL_YAML=kitchen.dokken.yml
   ```

   Or add to your shell profile (`~/.bashrc`, `~/.zshrc`, or use `mise.toml`):

   ```bash
   echo 'export KITCHEN_LOCAL_YAML=kitchen.dokken.yml' >> ~/.zshrc
   ```

2. **Verify setup**:

   ```bash
   kitchen list
   ```

   You should see Dokken as the driver for all instances.

### Running Tests

#### Run a single suite on one platform

```bash
kitchen test ident-16-debian-12
```

#### Run all platforms for a suite

```bash
kitchen test ident-16
```

#### Run specific suite on multiple platforms for verification

```bash
kitchen test ident-16-debian-12 ident-16-ubuntu-2204 ident-16-rockylinux-9
```

#### Debug a failing test

```bash
# Create and converge the instance
kitchen converge ident-16-debian-12

# Login to inspect
kitchen login ident-16-debian-12

# Inside the container, check PostgreSQL status
systemctl status postgresql-16
cat /var/lib/pgsql/16/data/pg_ident.conf
cat /var/lib/pgsql/16/data/pg_hba.conf
tail -f /var/lib/pgsql/16/data/log/postgresql-*.log

# Run tests manually
kitchen verify ident-16-debian-12

# Cleanup when done
kitchen destroy ident-16-debian-12
```

### Troubleshooting

#### Docker permission errors

```bash
# Linux: Add your user to docker group
sudo usermod -aG docker $USER
# Then logout and login again
```

#### Kitchen hangs or fails to start

```bash
# Clean up old containers
docker ps -a | grep kitchen | awk '{print $1}' | xargs docker rm -f

# Clean up dokken network
docker network prune
```

#### Tests pass locally but fail in CI

- Ensure you're using the same PostgreSQL version (check `node['test']['pg_ver']`)
- Check platform differences (RHEL vs Debian package names, paths)
- Review CI logs for specific error messages

### Test Suite Overview

- **access-\***: Tests `postgresql_access` resource (pg_hba.conf management)
- **client-install-\***: Tests client-only installation
- **extension-\***: Tests PostgreSQL extension installation
- **ident-\***: Tests `postgresql_ident` resource (pg_ident.conf management)
- **initdb-locale-\***: Tests database initialization with custom locale
- **server-install-\***: Tests full server installation
- **all-repos-install-\***: Tests installation with all repository options enabled
- **no-repos-install-\***: Tests installation without PGDG repositories
- **repo-\***: Tests repository configuration only
