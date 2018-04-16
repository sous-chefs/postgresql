# frozen_string_literal: true
Chef::Log.warn 'This cookbook is being re-written to use resources, not recipes and will only be Chef 13.8+ compatible. Please version pin to 6.1.1 to prevent the breaking changes from taking effect. See https://github.com/sous-chefs/postgresql/issues/512 for details'

Chef::Log.warn('The postgresql::ca-certificates recipe has been deprecated and will be removed in the next major release of the cookbook')
