#
# Cookbook Name:: postgresql
# Recipe::yum_pgdg_postgresql
#
# Copyright 2012, DonorsChoose.org
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
# The PostgreSQL RPM Building Project built repository RPMs for easy
# access to the PGDG yum repositories. Links to RPMs for installation
# on the supported version/platform combinations are listed at
# http://yum.postgresql.org/repopackages.php, and the links for
# PostgreSQL 8.4, 9.0, 9.1 and 9.2 (from 2012-12-09) are captured below.
#
# The correct RPM for installing /etc/yum.repos.d is based on:
# * the attribute configuring the desired Postgres Software:
#   node['postgresql']['version']        e.g., "9.1"
# * the chef ohai description of the target Operating System:
#   node['platform']                     e.g., "centos"
#   node['platform_version']             e.g., "5.7", truncated as "5"
#   node['kernel']['machine']            e.g., "i386" or "x86_64"

repo_rpm_url = {
  "9.2" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-centos92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-centos92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-centos92-9.2-6.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-sl92-9.2-8.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-sl92-9.2-8.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-sl92-9.2-8.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-sl92-9.2-8.noarch.rpm"
      }
    },
    "fedora" => {
      "17" => {
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-17-x86_64/pgdg-fedora92-9.2-5.noarch.rpm"
      },
      "16" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-16-i386/pgdg-fedora92-9.2-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-16-x86_64/pgdg-fedora92-9.2-5.noarch.rpm"
      },
      "15" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-15-i386/pgdg-fedora92-9.2-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-15-x86_64/pgdg-fedora92-9.2-5.noarch.rpm"
      }
    }
  },
  "9.1" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-redhat91-9.1-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-redhat91-9.1-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-redhat91-9.1-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-redhat91-9.1-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-redhat-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-redhat-9.1-4.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-sl91-9.1-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-sl91-9.1-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-sl91-9.1-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-sl91-9.1-6.noarch.rpm"
      }
    },
    "fedora" => {
      "16" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-16-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-16-x86_64/pgdg-fedora91-9.1-4.noarch.rpm"
      },
      "15" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-15-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-15-x86_64/pgdg-fedora91-9.1-4.noarch.rpm"
      },
      "14" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-14-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-14-x86_64/pgdg-fedora-9.1-2.noarch.rpm"
      }
    }
  },
  "9.0" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-sl90-9.0-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-sl90-9.0-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-sl90-9.0-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-sl90-9.0-6.noarch.rpm"
      }
    },
    "fedora" => {
      "15" => {
        "i386" => "http://yum.postgresql.org/9.0/fedora/fedora-15-i386/pgdg-fedora90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/fedora/fedora-15-x86_64/pgdg-fedora90-9.0-5.noarch.rpm"
      },
      "14" => {
        "i386" => "http://yum.postgresql.org/9.0/fedora/fedora-14-i386/pgdg-fedora90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/fedora/fedora-14-x86_64/pgdg-fedora90-9.0-5.noarch.rpm"
      }
    }
  },
  "8.4" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-sl84-8.4-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-sl84-8.4-4.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-sl-8.4-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-sl-8.4-4.noarch.rpm"
      }
    },
    "fedora" => {
      "14" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-14-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-14-x86_64/"
      },
      "13" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-13-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-13-x86_64/"
      },
      "12" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-12-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-12-x86_64/"
      },
      "8" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-8-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-8-x86_64/"
      },
      "7" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-7-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-7-x86_64/"
      }
    }
  },
}.fetch(node['postgresql']['version']).
  fetch(node['platform']).
  fetch(node['platform_version'].to_f.to_i.to_s).
  fetch(node['kernel']['machine'])

# Extract the filename portion from the URL for the PGDG repository RPM.
# E.g., repo_rpm_filename = "pgdg-centos92-9.2-6.noarch.rpm"
repo_rpm_filename = File.basename(repo_rpm_url)

# Extract the package name from the URL for the PGDG repository RPM.
# E.g., repo_rpm_package = "pgdg-centos92"
repo_rpm_package = repo_rpm_filename.split(/-/,3)[0..1].join('-')

######################################
# Install the "PostgreSQL RPM Building Project - Yum Repository" through
# the repo_rpm_url determined above. The /etc/yum.repos.d/pgdg-*.repo
# will provide postgresql9X packages, but you may need to exclude
# postgresql packages from the repository of the distro in order to use
# PGDG repository properly. Conflicts will arise if postgresql9X does
# appear in your distro's repo and you want a more recent patch level.

# Download the PGDG repository RPM as a local file
remote_file "#{Chef::Config[:file_cache_path]}/#{repo_rpm_filename}" do
  source "#{repo_rpm_url}"
  mode "0644"
end

# Install the PGDG repository RPM from the local file
# E.g., /etc/yum.repos.d/pgdg-91-centos.repo
package "#{repo_rpm_package}" do
  provider Chef::Provider::Package::Rpm
  source "#{Chef::Config[:file_cache_path]}/#{repo_rpm_filename}"
  action :install
end
