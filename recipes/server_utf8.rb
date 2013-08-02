#
# Ensures that Postgresql Server is installed with UTF-8 as the 
# default encoding.
#

ENV['LANG'] = ENV['LANGUAGE'] = ENV['LC_ALL'] = 'en_US.UTF-8'

include_recipe "postgresql::server"
