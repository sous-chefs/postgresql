# The PostgreSQL RPM Building Project built repository RPMs for easy
# access to the PGDG yum repositories. Links to RPMs for installation
# on the supported version/platform combinations are listed at
# http://yum.postgresql.org/repopackages.php, and the links for
# PostgreSQL 9.2, 9.3, 9.4, 9.5 and 9.6 are captured below.
#
default['postgresql']['pgdg']['repo_rpm_url'] = {
  '9.6' => {
    'amazon' => {
      '2015' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-i386/',
          'package' => 'pgdg-ami201503-96-9.6-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-ami201503-96-9.6-3.noarch.rpm'
        }
      }
    },
    'centos' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-centos96-9.6-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-i386/',
          'package' => 'pgdg-centos96-9.6-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-centos96-9.6-3.noarch.rpm'
        }
      }
    },
    'redhat' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-redhat96-9.6-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat96-9.6-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat96-9.6-3.noarch.rpm'
        }
      }
    },
    'oracle' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-oraclelinux96-9.6-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-i386/',
          'package' => 'pgdg-oraclelinux96-9.6-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-oraclelinux96-9.6-3.noarch.rpm'
        }
      }
    },
    'scientific' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-sl96-9.6-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-i386/',
          'package' => 'pgdg-sl96-9.6-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-sl96-9.6-3.noarch.rpm'
        }
      }
    },
    'fedora' => {
      '22' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/fedora/fedora-22-x86_64/',
          'package' => 'pgdg-fedora96-9.6-3.noarch.rpm'
        }
      },
      '23' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/fedora/fedora-23-x86_64/',
          'package' => 'pgdg-fedora96-9.6-3.noarch.rpm'
        }
      },
      '24' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.6/fedora/fedora-24-x86_64/',
          'package' => 'pgdg-fedora96-9.6-3.noarch.rpm'
        }
      }
    }
  },
  '9.5' => {
    'amazon' => {
      '2015' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-i386/',
          'package' => 'pgdg-ami201503-95-9.5-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-ami201503-95-9.5-3.noarch.rpm'
        }
      }
    },
    'centos' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-centos95-9.5-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-i386/',
          'package' => 'pgdg-centos95-9.5-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-centos95-9.5-3.noarch.rpm'
        }
      }
    },
    'redhat' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-redhat95-9.5-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat95-9.5-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat95-9.5-3.noarch.rpm'
        }
      }
    },
    'oracle' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-oraclelinux95-9.5-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-i386/',
          'package' => 'pgdg-oraclelinux95-9.5-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-oraclelinux95-9.5-3.noarch.rpm'
        }
      }
    },
    'scientific' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-sl95-9.5-3.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-i386/',
          'package' => 'pgdg-sl95-9.5-3.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-sl95-9.5-3.noarch.rpm'
        }
      }
    },
    'fedora' => {
      '22' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/fedora/fedora-22-x86_64/',
          'package' => 'pgdg-fedora95-9.5-3.noarch.rpm'
        }
      },
      '23' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/fedora/fedora-23-x86_64/',
          'package' => 'pgdg-fedora95-9.5-4.noarch.rpm'
        }
      },
      '24' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.5/fedora/fedora-24-x86_64/',
          'package' => 'pgdg-fedora95-9.5-4.noarch.rpm'
        }
      }
    }
  },
  '9.4' => {
    'redhat' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-redhat94-9.4-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat94-9.4-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat94-9.4-2.noarch.rpm'
        }
      }
    },
    'centos' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-centos94-9.4-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/',
          'package' => 'pgdg-centos94-9.4-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-centos94-9.4-2.noarch.rpm'
        }
      }
    },
    'fedora' => {
      '22' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/fedora/fedora-22-x86_64/',
          'package' => 'pgdg-fedora94-9.4-4.noarch.rpm'
        }
      },
      '23' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/fedora/fedora-23-x86_64/',
          'package' => 'pgdg-fedora94-9.4-5.noarch.rpm'
        }
      },
      '24' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/fedora/fedora-24-x86_64/',
          'package' => 'pgdg-fedora94-9.4-5.noarch.rpm'
        }
      }
    },
    'amazon' => {
      '2015' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/',
          'package' => 'pgdg-ami201503-94-9.4-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-ami201503-94-9.4-2.noarch.rpm'
        }
      }
    },
    'scientific' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-sl94-9.4-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/',
          'package' => 'pgdg-sl94-9.4-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-sl94-9.4-2.noarch.rpm'
        }
      }
    },
    'oracle' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-oraclelinux94-9.4-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-i386/',
          'package' => 'pgdg-oraclelinux94-9.4-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-oraclelinux94-9.4-2.noarch.rpm'
        }
      }
    }
  },
  '9.3' => {
    'amazon' => {
      '2015' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        }
      },
      '2014' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        }
      }
    },
    'centos' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-centos93-9.3-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-centos93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-centos93-9.3-2.noarch.rpm'
        }
      }
    },
    'fedora' => {
      '23' => {
        'x86_64' => {
          'url' => 'https://yum.postgresql.org/9.3/fedora/fedora-23-x86_64/',
          'package' => 'pgdg-fedora93-9.3-4.noarch.rpm'
        }
      }
    },
    'redhat' => {
      '7' => {
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        }
      },
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        }
      }
    },
    'oracle' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat93-9.3-2.noarch.rpm'
        }
      }
    },
    'scientific' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-i386/',
          'package' => 'pgdg-sl93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-sl93-9.3-2.noarch.rpm'
        }
      },
      '5' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-i386/',
          'package' => 'pgdg-sl93-9.3-2.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/',
          'package' => 'pgdg-sl93-9.3-2.noarch.rpm'
        }
      }
    }
  },
  '9.2' => {
    'centos' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/',
          'package' => 'pgdg-centos92-9.2-7.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-centos92-9.2-7.noarch.rpm'
        }
      }
    },
    'redhat' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat92-9.2-7.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat92-9.2-7.noarch.rpm'
        }
      }
    },
    'oracle' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/',
          'package' => 'pgdg-redhat92-9.2-7.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-redhat92-9.2-7.noarch.rpm'
        }
      }
    },
    'scientific' => {
      '6' => {
        'i386' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-i386/',
          'package' => 'pgdg-sl92-9.2-8.noarch.rpm'
        },
        'x86_64' => {
          'url' => 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/',
          'package' => 'pgdg-sl92-9.2-8.noarch.rpm'
        }
      }
    }
  }
}
