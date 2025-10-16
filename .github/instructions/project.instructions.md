# Copilot Project Instructions: postgresql Cookbook (Specific)

This file provides cookbook-specific instructions for Copilot and other AI coding assistants. It supplements, but does not duplicate, the general instructions in `.github/copilot-instructions.md`.

## Cookbook Purpose

- The `postgresql` cookbook manages installation, configuration, and access control for PostgreSQL database servers.
- It provides custom Chef resources for PostgreSQL installation, service management, user/database creation, access control, and configuration.
- Supports multiple PostgreSQL versions and major Linux distributions (see `metadata.rb`, `kitchen.yml`).

## Key Custom Resources

- `postgresql_install`: Installs and initializes PostgreSQL server.
- `postgresql_service`: Manages the PostgreSQL system service (start, stop, restart, enable, etc.).
- `postgresql_access`: Manages entries in `pg_hba.conf` for access control.
- `postgresql_user`: Creates, updates, and manages PostgreSQL users and roles.
- `postgresql_database`: Creates and manages databases.
- `postgresql_config`: Manages configuration files.
- `postgresql_extension`, `postgresql_ident`, `postgresql_role`: Additional resources for advanced PostgreSQL features.

## Cookbook-Specific Patterns

- All access control changes (`postgresql_access`) must ensure the config file is written before triggering a service restart.
- Helper modules in `libraries/` are used for parsing and manipulating PostgreSQL config files.
- Example usage and test coverage for all resources is found in `test/cookbooks/test/recipes/`.
- Templates for configuration files are located in `templates/default/`.

## Testing and Validation

- Integration tests cover multiple OS and PostgreSQL versions (see `.kitchen/logs/` for matrix).
- Example test recipes demonstrate resource usage and edge cases (e.g., usernames with dashes, multiple databases/users, LDAP auth).

## Documentation

- Resource documentation is in `documentation/` and includes usage examples and property details for each resource.

## Special Notes

- This cookbook is resource-driven; recipes are only used for testing and examples.
- All changes must maintain idempotency and proper notification sequencing for service restarts.
- Do not bypass resource logic—always use the provided custom resources for PostgreSQL management.

For general build, test, and workflow instructions, refer to `.github/copilot-instructions.md`.
