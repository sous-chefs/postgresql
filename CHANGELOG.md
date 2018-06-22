# postgresql Cookbook CHANGELOG

This file is used to list changes made in the last 3 major versions of the postgresql cookbook.

## v7.1.0 (22-06-2018)

- Update the `initdb` script to use initdb rather than a service. #542
- Refactor database commands to use the common connect method. #535
- Increase the unit test coverage.

## v7.0.0 (25-05-2018)

_Breaking Change_ Please see UPGRADING.md and the README.md for information how to use.

- Add custom resources for:

  - `postgresql_client_install`
  - `postgresql_server_install`
  - `postgresql_repository`
  - `postgresql_pg_gem`

- Deprecate recipes:

  - `apt_pgdg_postgresql`
  - `config_initdb`
  - `config_pgtune`
  - `contrib`
  - `ruby`
  - `yum_pgdg_postgresql`

- Remove deprecated tests

## v6.1.3 (2018-04-18)

- Fix recipes referencing the old helpers

## v6.1.2 (2018-04-16)

**this will be the last release of the 6.0 series before all recipes are removed from the cookbook**

- Deprecate all recipes

## v6.1.1 (2017-03-08)

- Fix pg gem installation on non-omnibus chef runs
- Resolve resource cloning deprecation warnings in the ruby recipe
- Fix issues resolving the timezone on CentOS 7 and probably other distros
- Test with Delivery local instead of Rake

## v6.1.0 (2017-02-18)

- Fix a method name conflict that caused errors if Chef Sugar was also being used on the run list
- Revert a previous PR that added support for Postgresql 9.6 as it introduced incorrect configuration values
- Added Fedora 25 support for pgdg packages
- Added RHEL 5 support for Postgresql 9.4 pgdg packages
- Removed testing for RHEL 5 and Ubuntu 12.04 as they are scheduled for EoL in the near future
- Improvements to Test Kitchen testing to allow more extensive testing in Travis CI
- Fixed the client recipe on Fedora
- Added Inspec tests for client installs

## v6.0.1 (2017-01-04

- Fix systemd unit file template

## v6.0.0 (2017-01-03)

- This cookbook now requires Chef 12.1 or later
- Removed the dependency on the apt cookbook as this functionality is built into modern chef client releases
- Added a new custom resource for installing extensions. This acts as a replacement for the contrib recipe with minimal backwards compatibility. You can now install / remove extensions into any database. This adds the compat_resource cookbook dependency so we can continue to support Chef 12.1-12.4, which lack custom resource support.
- The unused get_result_orig helper has been removed. If you utilized this you'll want to move it to your own wrapper cookbook
- Updates for compatibility with Postgresql 9.5 and 9.6
- Fixed client package installation on openSUSE Leap 42.2
- ca-certificates recipe has been deprecated. If ca-certificates package needs to be upgraded the user should do so prior to including this recipe. Package upgrades in community cookbooks are generally a bad idea as this bring in updated packages to production systems. The recipe currently warns if used and will be removed with the next major cookbook release.
- Fixed RHEL platform detection in the Ruby recipe
- systemd fixes for RHEL systems
- Fix systemd service file include when using pgdg packages
- Package installation now uses multi-package installs to speed up converge times
- Added integration testing in Travis of the client recipe using a new test cookbook. This will be expanded in the future to cover server installation as well
- Expanded the specs to test converges on multiple platforms

## v5.2.0 (2016-12-30)

- Updated contacts and links to point to Sous Chefs now
- Added a Code of Conduct (the Chef CoC)
- Removed duplicate platforms in the metadata
- Fix Chef runs with local mode in the server recipe
- Fix the ruby recipe to not fail when you specify enabling both the apt and yum repos for mixed distro environments
- Set the postgresql data directory to 700 permissions
- Added node['postgresql']['pg_gem']['version'] to specify the version of the pg gem to install
- Cookstyle fixes for the latest cookstyle release
- Removed test deps from the Gemfile. Rely on ChefDK for base testing deps instead

## v5.1.0 (2016-11-01)

- Maintenance of this cookbook has been migrated from Heavy Water to Sous Chefs - <https://sous-chefs.org/>
- Add support for Chef-Zero (local mode)
- Don't hardcode the UID / GID on RHEL/Amazon/Suse platforms
- Add PGDG yum RPMs for 9.5 / 9.6

## v5.0.0 (2016-10-25)

### Breaking changes

- Switched from Librarian to Berkshelf
- Remove support for the following platforms

  - SLES < 12
  - openSUSE < 13
  - Debian < 7
  - Ubuntu < 12.04
  - RHEL < 6
  - Amazon < 2013
  - Unsupported (EOL) Fedora releases

### Other changes

- Added support for Ubuntu 16.04
- Loosened cookbook dependencies to not prevent pulling in the latest community cookbooks
- Added chef_version metadata
- Switched from rubocop to cookstyle and fix all warnings
- Removed minitests and the minitest handler
- Added support for opensuse / opensuseleap
- Added support for Fedora 23/24
- Added a chefignore file to limit the files uploaded to the chef server
- Updated Test Kitchen config to test on modern platform releases
- Added a Rakefile and updated Travis to test with ChefDK and that rakefile
- Avoid installing packages included in build-essential twice in the ruby recipe
- Require at least build-essential 2.0
- Don't cleanup the old PPA files in the apt_pgdg_postgresql recipe anymore. These should be long gone everywhere
- Remove logic in the apt_pgdg_postgresql recipe that made Chef fail when new distro releases came out
- Avoid node.set deprecation warnings
- Avoid managed_home deprecation warnings in server_redhat recipe
