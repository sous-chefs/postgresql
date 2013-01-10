#
# Cookbook Name:: postgresql
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

######################################
# Major Linux distributions "snapshot" a specific version of PostgreSQL
# that is then supported throughout the lifetime of that platform.
# It is often not possible to get recent PostgreSQL 9.X releases through
# distro-specific repos. Fortunately, RPM builds for recent PostgreSQL
# releases are maintained for major Linux distros.
#
# Newer versions of PostgreSQL ...
#
# ... for older versions of Debians are available in Debian backports.
# (http://backports-master.debian.org/Instructions/)
#
# ... for a specific Ubuntu version are available in the PostgreSQL
# backports PPA repository.
# (https://launchpad.net/~pitti/+archive/postgresql/)
#
# ... for openSUSE are available through the openSUSE Build Service.
# (http://en.opensuse.org/openSUSE:Build_Service_Installation_SUSE)
#
# ... for other various Linux platform_family groups ("rhel", "fedora")
# are available through the PostgreSQL Global Development Group (PGDG).
# (http://yum.postgresql.org/howtoyum.php)
#
# Using alternative repos instead of waiting for downstream packages to
# appear in distro-specific repos makes it possible to consistently
# have up-to-date, full-featured packages that install easily.
 
######################################
# Those platforms use two main package naming conventions, so this
# cookbook relies on the platform description determined by ohai (the
# node platform_family or the specific platform and platform_version).
#
# These package names are generally used in the "debian" platform_family
# (Debian and Ubuntu), but there is some variation:
#     postgresql-client-9.X - client libraries and client binaries
#     postgresql-9.X - core database server
#     postgresql-contrib-9.X - additional supplied modules
#
# These package names seem to be used consistently by other platforms:
#     postgresql9X-devel - PostgreSQL client programs and libraries
#     postgresql9X-server - The programs needed to create and run a PostgreSQL server
#     postgresql9X-contrib - Contributed source and binaries distributed with PostgreSQL

case node['platform']
when "debian", "ubuntu"
  client_package_name="postgresql-client-#{node['postgresql']['version']}"
  server_package_name="postgresql-#{node['postgresql']['version']}"
  contrib_package_name="postgresql-contrib-#{node['postgresql']['version']}"
else
  client_package_name="postgresql#{node['postgresql']['version'].split('.').join}-devel"
  server_package_name="postgresql#{node['postgresql']['version'].split('.').join}-server"
  contrib_package_name="postgresql#{node['postgresql']['version'].split('.').join}-contrib"
end

######################################
# Install a repository RPM to provide an APT or YUM repository for
# the platform which maintains recent PostgreSQL packages.

case node['platform']
when "debian"
  # If possible, use the official Debian distribution
  # (i.e., http://www.debian.org/distrib/packages)
  # postgresql-9.1 appeared in Debian wheezy (7.0? testing)
  # postgresql-9.2 had not appeared in Debian sid (8.0? unstable)
  if ( node['platform_version'].to_f < 7 and
       node['postgresql']['version'].to_f > 8.4 ) or
     ( node['postgresql']['version'].to_f > 9.1 )
    Chef::Log.warn "You probably need to add Debian backports to your sources.list"
    Chef::Log.warn "(See http://packages.debian.org/squeeze-backports/)"
    unless node['postgresql']['client']['packages'].include?(client_package_name) and
           node['postgresql']['server']['packages'].include?(server_package_name) and
           node['postgresql']['contrib']['packages'].include?(contrib_package_name)
      Chef::Log.warn "You probably need package names with explicit #{node['postgresql']['version']} versions"
      Chef::Log.warn "(node['postgresql']['client']['packages'] = \"#{client_package_name}\")"
      Chef::Log.warn "(node['postgresql']['server']['packages'] = \"#{server_package_name}\")"
      Chef::Log.warn "(node['postgresql']['contrib']['packages'] = \"#{contrib_package_name}\")"
    end
  end

when "ubuntu"
  # If possible, use the official Ubuntu distribution
  # (i.e., http://packages.ubuntu.com/)
  # postgresql-9.1 appeared in Ubuntu 11.04
  # postgresql-9.2 had not appeared by Ubuntu 12.10
  if ( node['platform_version'].to_f <= 11.04 and
       node['postgresql']['version'].to_f > 8.4 ) or
     ( node['postgresql']['version'].to_f > 9.1 )
    unless node['postgresql']['enable_pitti_ppa']
      Chef::Log.warn "You probably need to use the PostgreSQL backport PPA repository"
      Chef::Log.warn "(node['postgresql']['enable_pitti_ppa'] = true)"
    end
    unless node['postgresql']['client']['packages'].include?(client_package_name) and
           node['postgresql']['server']['packages'].include?(server_package_name) and
           node['postgresql']['contrib']['packages'].include?(contrib_package_name)
      Chef::Log.warn "You probably need package names with explicit #{node['postgresql']['version']} versions"
      Chef::Log.warn "(node['postgresql']['client']['packages'] = \"#{client_package_name}\")"
      Chef::Log.warn "(node['postgresql']['server']['packages'] = \"#{server_package_name}\")"
      Chef::Log.warn "(node['postgresql']['contrib']['packages'] = \"#{contrib_package_name}\")"
    end
  end

when "redhat", "centos", "fedora", "scientific"
  if ( node['postgresql']['version'].to_f > 8.4 )
    unless node['postgresql']['enable_pgdg_yum']
      Chef::Log.warn "You probably need to set up the PGDG repository"
      Chef::Log.warn "(node['postgresql']['enable_pgdg_yum'] = true)"
    end
    unless node['postgresql']['client']['packages'].include?(client_package_name) and
           node['postgresql']['server']['packages'].include?(server_package_name) and
           node['postgresql']['contrib']['packages'].include?(contrib_package_name)
      Chef::Log.warn "You probably need package names with explicit #{node['postgresql']['version']} versions"
      Chef::Log.warn "(node['postgresql']['client']['packages'] = \"#{client_package_name}\")"
      Chef::Log.warn "(node['postgresql']['server']['packages'] = \"#{server_package_name}\")"
      Chef::Log.warn "(node['postgresql']['contrib']['packages'] = \"#{contrib_package_name}\")"
    end
  end

when "amazon"
  if ( node['postgresql']['version'].to_f > 8.4 )
    unless node['postgresql']['enable_pgdg_yum']
      Chef::Log.warn "You probably need to set up the PGDG repository"
      Chef::Log.warn "(node['postgresql']['enable_pgdg_yum'] = true)"
    end
    Chef::Log.warn "Note that others have found they need to change the baseurl"
    Chef::Log.warn "settings in the /etc/yum.repos.d/pgdg-9X-redhat.repo file"
    unless node['postgresql']['client']['packages'].include?(client_package_name) and
           node['postgresql']['server']['packages'].include?(server_package_name) and
           node['postgresql']['contrib']['packages'].include?(contrib_package_name)
      Chef::Log.warn "You probably need package names with explicit #{node['postgresql']['version']} versions"
      Chef::Log.warn "(node['postgresql']['client']['packages'] = \"#{client_package_name}\")"
      Chef::Log.warn "(node['postgresql']['server']['packages'] = \"#{server_package_name}\")"
      Chef::Log.warn "(node['postgresql']['contrib']['packages'] = \"#{contrib_package_name}\")"
    end
  end

when "suse"
  if ( node['platform_version'].to_f <= 11.1 and
       node['postgresql']['version'].to_f > 8.3 ) or
     ( node['postgresql']['version'].to_f > 9.0 )
    Chef::Log.warn "You probably need to set up the openSUSE Build Service"
    Chef::Log.warn "(See http://en.opensuse.org/openSUSE:Build_Service_Installation_SUSE)"
    Chef::Log.warn "in order to use a server:database:postgresql repostory"
    Chef::Log.warn "(See https://build.opensuse.org/project/repositories?project=server%3Adatabase%3Apostgresql)"
    unless node['postgresql']['client']['packages'].include?(client_package_name) and
           node['postgresql']['server']['packages'].include?(server_package_name) and
           node['postgresql']['contrib']['packages'].include?(contrib_package_name)
      Chef::Log.warn "You probably need package names with explicit #{node['postgresql']['version']} versions"
      Chef::Log.warn "(node['postgresql']['client']['packages'] = \"#{client_package_name}\")"
      Chef::Log.warn "(node['postgresql']['server']['packages'] = \"#{server_package_name}\")"
      Chef::Log.warn "(node['postgresql']['contrib']['packages'] = \"#{contrib_package_name}\")"
    end
  end

end

######################################

include_recipe "postgresql::client"
