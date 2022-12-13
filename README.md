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

If you are wondering where all the recipes went in v7.0+, or how on earth I use this new cookbook please see UPGRADING.md for a full description.

## Requirements

### Platforms

- Amazon Linux
- Debian 9+
- Ubuntu 18.04+
- Red Hat/CentOS/Scientific 7+

### PostgreSQL version

We follow the currently supported versions listed on <https://www.postgresql.org/support/versioning/>

### Chef

- Chef 16

### Cookbook Dependencies

- `yum` >= 7.2.0 (for `dnf_module` resource)

## Resources

- [postgresql_access](documentation/postgresql_access.md)
- [postgresql_config](documentation/postgresql_config.md)
- [postgresql_database](documentation/postgresql_database.md)
- [postgresql_extension](documentation/postgresql_extension.md)
- [postgresql_ident](documentation/postgresql_ident.md)
- [postgresql_install](documentation/postgresql_install.md)
- [postgresql_role](documentation/postgresql_role.md)
- [postgresql_service](documentation/postgresql_service.md)

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
