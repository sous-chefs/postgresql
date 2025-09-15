# PostgreSQL Chef Cookbook Development Guide

The PostgreSQL cookbook is a Chef cookbook that provides resources for installing and configuring PostgreSQL database servers and clients across multiple Linux distributions and PostgreSQL versions (15, 16, 17).

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Environment Setup
- **CRITICAL**: Ruby development environment setup (required for all tasks):
  ```bash
  # Install Ruby development tools (required for linting and testing)
  gem install --user-install bundler cookstyle deepsort inifile
  
  # ALWAYS set PATH for user-installed gems before running any cookbook commands
  export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
  ```

### Linting and Code Quality
- **VALIDATED**: Run Cookstyle linter (takes ~2-3 seconds):
  ```bash
  export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
  cookstyle .
  ```
- **VALIDATED**: Check Ruby syntax (instant):
  ```bash
  ruby -c libraries/helpers.rb
  ruby -c resources/install.rb
  # Check any .rb file for syntax errors
  ```
- **ALWAYS run `cookstyle .` before committing changes** - the CI will fail if there are style violations

### Testing Limitations in Sandbox Environment
- **RSpec/ChefSpec unit tests**: Cannot run due to gem version conflicts between RSpec versions
- **Test Kitchen integration tests**: Cannot run due to blocked network access to supermarket.chef.io
- **Docker/Vagrant testing**: Not available in sandbox environment
- **Working alternative**: Use syntax checking and Cookstyle linting for validation

### What Works for Development
- All Ruby file syntax validation
- Cookstyle linting and style checking  
- Code exploration and modification
- Documentation updates
- Resource parameter validation through code review

## Repository Structure

### Key Locations
- **Resources**: `/resources/` - Main cookbook functionality (install.rb, config.rb, service.rb, etc.)
- **Libraries**: `/libraries/` - Helper modules and utility functions 
- **Test Examples**: `/test/cookbooks/test/recipes/` - Example usage patterns for each resource
- **Documentation**: `/documentation/` - Detailed resource documentation
- **Integration Tests**: `/test/integration/` - InSpec test suites (reference only in sandbox)

### Important Files
- `metadata.rb` - Cookbook metadata, dependencies, and supported platforms
- `kitchen.yml` - Test Kitchen configuration (defines test suites and platforms)
- `.rubocop.yml` - Cookstyle/RuboCop linting configuration
- `Berksfile` - Cookbook dependency management (network dependent)

## Common Development Tasks

### Adding New Functionality
1. Modify resources in `/resources/` directory
2. Update helper libraries in `/libraries/` if needed
3. Add example usage in `/test/cookbooks/test/recipes/`
4. Update documentation in `/documentation/`
5. **ALWAYS run**: `cookstyle .` before committing
6. **ALWAYS run**: `ruby -c filename.rb` for syntax validation

### Resource Development
- Main resources: `postgresql_install`, `postgresql_config`, `postgresql_service`, `postgresql_database`, `postgresql_role`, `postgresql_access`, `postgresql_ident`, `postgresql_extension`
- Each resource has corresponding documentation in `/documentation/postgresql_[resource].md`
- Example usage patterns available in `/test/cookbooks/test/recipes/`

### Dependencies and Platforms
- **Dependencies**: Requires `yum` cookbook (>= 7.2.0) for DNF module resource
- **Supported platforms**: Amazon Linux, Debian 9+, Ubuntu 18.04+, Red Hat/CentOS/Scientific 7+
- **PostgreSQL versions**: 15, 16, 17 (following official PostgreSQL support policy)
- **Chef version**: Requires Chef 16+

## Validation Workflows

### Before Committing
1. **NEVER skip**: `export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"`
2. **ALWAYS run**: `cookstyle .` (takes 2-3 seconds, NEVER CANCEL)
3. **ALWAYS run**: `ruby -c` on any modified .rb files  
4. Review changes against existing patterns in `/test/cookbooks/test/recipes/`

### CI/CD Expectations  
- GitHub Actions CI runs on 12+ OS platforms with 3 PostgreSQL versions
- Integration tests use Test Kitchen with Docker (kitchen.dokken.yml)
- Lint-unit workflow must pass before integration tests run
- **Timeout expectations**: CI integration tests can take 15-30+ minutes per platform/version combination

## Working with Limited Network Access
- **Cannot access**: supermarket.chef.io for cookbook dependencies
- **Cannot run**: `berks install` or full Test Kitchen suites
- **Can validate**: Code syntax, style, and logical structure
- **Best practice**: Use existing test recipes as patterns for new functionality

## Key Configuration Files Referenced
```
ls -la [repo-root]
.
..
.github/               # GitHub workflows and this instruction file
.rubocop.yml          # Cookstyle configuration  
.overcommit.yml       # Git hooks configuration
Berksfile             # Cookbook dependencies (network dependent)
CHANGELOG.md          # Version history
CODE_OF_CONDUCT.md    # Community guidelines
CONTRIBUTING.md       # Contribution guidelines  
LICENSE               # Apache 2.0 license
README.md             # Main cookbook documentation
TESTING.md            # Testing guidelines
UPGRADING.md          # Version upgrade instructions
documentation/        # Resource documentation
kitchen.yml           # Test Kitchen configuration
libraries/            # Helper libraries and utilities
metadata.rb           # Cookbook metadata and dependencies
resources/            # Main cookbook resources
spec/                 # Unit test specifications (RSpec/ChefSpec)
test/                 # Integration tests and test cookbooks
```

## Performance Notes
- **Cookstyle linting**: ~2-3 seconds for full cookbook
- **Ruby syntax checking**: Instant per file  
- **Full CI integration suite**: 15-30+ minutes (multiple platforms/versions)
- **File validation**: Use syntax checking over attempting to run code in sandbox
