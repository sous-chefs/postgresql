This cookbook includes support for running unit tests under ChefSpec and integration tests under Test Kitchen.

Before you can run these tests:

1. You must be using the Git repository, rather than the downloaded cookbook from the Chef Community Site.
2. You must have Vagrant 1.1 installed.
3. You must have a "sane" Ruby 1.9.3 environment with `bundler`

Once the above requirements are met, install the gem dependenies:

    bundle install

With the bundle installed, you should be able to run Test Kitchen:

    bundle exec kitchen list
    bundle exec kitchen test

You can use the tasks defined in the Rakefile for running tests. For example, the following commands will run
the ChefSpec unit tests and all of the configured Test Kitchen platform/suite permuations:

   bundle exec rake spec
   bundle exec rake kitchen:all
