# The PostgreSQL RPM Building Project built repository RPMs for easy
# access to the PGDG yum repositories. Links to RPMs for installation
# on the supported version/platform combinations are listed at
# http://yum.postgresql.org/repopackages.php, and the links for
# PostgreSQL 9.2, 9.3 and 9.4 are captured below.
#
default['postgresql']['pgdg']['repo_rpm_url'] = {
  "9.4" => {
    "redhat" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/",
          "package" => "pgdg-redhat94-9.4-2.noarch.rpm",
          "checksum" => "785ebdd992b8468627841a42f15146f677b9c468ca6f2bee0151de9765e9d9ad",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat94-9.4-2.noarch.rpm",
          "checksum" => "3a1c6eab3441ee32666852442424812ed9ced3a24f0b35757b43fc0fec7bc682",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat94-9.4-2.noarch.rpm",
          "checksum" => "092c20593efd9ee38f4cd5b01d7e6f9c3eef37bd5d322d0f72a63f81c8d9b0f3",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-i386/",
          "package" => "pgdg-redhat94-9.4-2.noarch.rpm",
          "checksum" => "e957fe028b80105aa4de021bde9baa30272ae21e7a862378c002e9294ca3939d",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-x86_64/",
          "package" => "pgdg-redhat94-9.4-2.noarch.rpm",
          "checksum" => "9dcdf39fdaf40d7d2870bdb0134f4d05f9a1a469339640fec4c2628aa2bfd191",
        }
      }
    },
    "centos" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/",
          "package" => "pgdg-centos94-9.4-2.noarch.rpm",
          "checksum" => "f46798a7a0780568112256854562436bc2158f4705d08439ffc850d97fc15f6c",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/",
          "package" => "pgdg-centos94-9.4-2.noarch.rpm",
          "checksum" => "73b9165257601cfcade49c345c8a663444234cebbc67afb3e43100c5b488bdc4",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/",
          "package" => "pgdg-centos94-9.4-2.noarch.rpm",
          "checksum" => "d31775b126ab1ba433252d66114a7b8776ce2d13d0f138556e143dee857fb7fa",
        }
      },
      "5" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-x86_64/",
          "package" => "pgdg-centos94-9.4-2.noarch.rpm",
          "checksum" => "3c8a88164f93a5852ec79237c55d9bbe05a9e4be474471124e0a585d9e1b85e1",
        },
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-i386/",
          "package" => "pgdg-centos94-9.4-2.noarch.rpm",
          "checksum" => "73993b12060116456cf52e96edd64ed36c4805515b265e48027b46c89cc84005",
        }
      }
    },
    "fedora" => {
      "22" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/fedora/fedora-22-x86_64/",
          "package" => "pgdg-fedora94-9.4-3.noarch.rpm",
          "checksum" => "2724908dfc6e58f46fb549d6d491331a76d505d89bfccdee14e29b4dbe3424e3",
        }
      },
      "21" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/fedora/fedora-21-x86_64/",
          "package" => "pgdg-fedora94-9.4-2.noarch.rpm",
          "checksum" => "5651f7882e4884516aeefd4239aa369c5b95bd905b760d5860c9747421f897b9",
        },
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/fedora/fedora-21-i686/",
          "package" => "pgdg-fedora94-9.4-2.noarch.rpm",
          "checksum" => "9c09df4df0d06e4fa78f83b050e693d21853034cda05198a3e4e8f16e0b69388",
        }
      },
      "20" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/fedora/fedora-20-x86_64/",
          "package" => "pgdg-fedora94-9.4-1.noarch.rpm",
          "checksum" => "5c89ebcafb0de979ae88302de3e7f536bdcf22d3f6c16a0bc980e7c643b870e8",
        },
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/fedora/fedora-20-i686/",
          "package" => "pgdg-fedora94-9.4-1.noarch.rpm",
          "checksum" => "69b27dcc451cfb6335c47e53645edc7f5e6af1c6bd2d33e0bf2130b3675e32bb",
        }
      }
    },
    "amazon" => {
      "2015" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/",
          "package" => "pgdg-ami201503-94-9.4-2.noarch.rpm",
          "checksum" => "1466b4643f9d4a20757825510256196406b817ff875d124d5195118b456d1450",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/",
          "package" => "pgdg-ami201503-94-9.4-2.noarch.rpm",
          "checksum" => "accba99266316352c2f8a821c3b2937c9457da3259158be845afa7b70893995b",
        }
      }
    },
    "scientific" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/",
          "package" => "pgdg-sl94-9.4-2.noarch.rpm",
          "checksum" => "ea45f990c7661bd49e925ecaeef65c61f639bf44fb710fbc93b457aca164657d",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/",
          "package" => "pgdg-sl94-9.4-2.noarch.rpm",
          "checksum" => "574b6bf6da20ae51dde898a0dc2e9211bf3beb5d766e969d3f719df1e72f4ce8",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/",
          "package" => "pgdg-sl94-9.4-2.noarch.rpm",
          "checksum" => "2b1eb6e6115e4aa096de4aeb9ff969a0170e32b45e80752bf69e52c4ef71b4b1",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-i386/",
          "package" => "pgdg-sl94-9.4-2.noarch.rpm",
          "checksum" => "5d5d8ba91a9b7aa9c5fd53265e1cd47cd27d0ecc28ce63cd3df5678a8bf07102",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-5-x86_64/",
          "package" => "pgdg-sl94-9.4-2.noarch.rpm",
          "checksum" => "a52a83b5546d0b739e919e66720337045cd8e44f39d4adb847563f143a6fbca4",
        }
      }
    },
    "oracle" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/",
          "package" => "pgdg-oraclelinux94-9.4-2.noarch.rpm",
          "checksum" => "bfe1b188e0d1d7efdceb6e4d347782a67fe4a4af940e903905bf6c0d4e18d247",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-i386/",
          "package" => "pgdg-oraclelinux94-9.4-2.noarch.rpm",
          "checksum" => "f84bc9be0ce22cf3aaaab433d5ab63f82b22930bcec1bb1dfd13002de4cee5e4",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/",
          "package" => "pgdg-oraclelinux94-9.4-2.noarch.rpm",
          "checksum" => "590aa88abf23bb8bb588308300dca5e232a4a277c1cf0a71fc229990ed56f4dd",
        }
      }
    }
  },
  "9.3" => {
    "amazon" => {
      "2015" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "bae19677bcc02685a7946fdbc487ffab659fd6fdaa5cf6e400d9c08aba93d819",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "a1f118110b2d0f255e334850a1871a8c4d6f4bfb5e3a385bdb22e13146a69ef6",
        }
      },
      "2014" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "bae19677bcc02685a7946fdbc487ffab659fd6fdaa5cf6e400d9c08aba93d819",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "a1f118110b2d0f255e334850a1871a8c4d6f4bfb5e3a385bdb22e13146a69ef6",
        }
      },
      "2013" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "bae19677bcc02685a7946fdbc487ffab659fd6fdaa5cf6e400d9c08aba93d819",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "a1f118110b2d0f255e334850a1871a8c4d6f4bfb5e3a385bdb22e13146a69ef6",
        }
      }
    },
    "centos" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/",
          "package" => "pgdg-centos93-9.3-2.noarch.rpm",
          "checksum" => "f36ac9c1bd10f7277349417f8ee061e16345c868310560551a421a8a8a8ff563",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-centos93-9.3-2.noarch.rpm",
          "checksum" => "09486b6a9a448b8f6f4aeae209c0f8163d56a4ef7974af36ee8def6398a3b7f8",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-centos93-9.3-2.noarch.rpm",
          "checksum" => "5171a533106d32fb49b25d08bb12467e26fac3d8174ca5630b381c528640f1fd",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/",
          "package" => "pgdg-centos93-9.3-2.noarch.rpm",
          "checksum" => "4a2e53e4a531b032cce929c5dcab38f8467e1a38a1525038b711cf3b56afc5f4",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/",
          "package" => "pgdg-centos93-9.3-2.noarch.rpm",
          "checksum" => "70bfef9b1f6200645a334b8138b99ec01bc74487bbeed41022be97efc0171e72",
        }
      }
    },
    "redhat" => {
      "7" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "d5dc1fc70a7f744c15879c4429bdbf4c6555cfe82be0c30792033d6030e11f6f",
        }
      },
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "bae19677bcc02685a7946fdbc487ffab659fd6fdaa5cf6e400d9c08aba93d819",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "a1f118110b2d0f255e334850a1871a8c4d6f4bfb5e3a385bdb22e13146a69ef6",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "61207682bcc83d9f04958ae005724b6dcc9e499f561ed3d7546ba630c4db559e",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "18768fd0783a7b94c58f7423b077c775f4be43485ddae7600086a2510f3c671a",
        }
      }
    },
    "oracle" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "bae19677bcc02685a7946fdbc487ffab659fd6fdaa5cf6e400d9c08aba93d819",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "a1f118110b2d0f255e334850a1871a8c4d6f4bfb5e3a385bdb22e13146a69ef6",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "61207682bcc83d9f04958ae005724b6dcc9e499f561ed3d7546ba630c4db559e",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/",
          "package" => "pgdg-redhat93-9.3-2.noarch.rpm",
          "checksum" => "18768fd0783a7b94c58f7423b077c775f4be43485ddae7600086a2510f3c671a",
        }
      }
    },
    "scientific" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/",
          "package" => "pgdg-sl93-9.3-2.noarch.rpm",
          "checksum" => "3f5a9919dd9c055a9cd7016c4b86ffa3f2ae51ba35c8316ad13eba82404e7ac7",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/",
          "package" => "pgdg-sl93-9.3-2.noarch.rpm",
          "checksum" => "df16962d1a15483db72b8ed5264986a9ee0139e40c7ab275314c705a682c92f5",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/",
          "package" => "pgdg-sl93-9.3-2.noarch.rpm",
          "checksum" => "4c1b11368ccf157e5c5a36e65a2afc9a8c066f6e51ddd53b612f94c997386ab3",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/",
          "package" => "pgdg-sl93-9.3-2.noarch.rpm",
          "checksum" => "c49f4060e6d3ca0ae32ddab2dda768882ebc3ff3c0030e58dc7e7506ca522e52",
        }
      }
    },
    "fedora" => {
      "20" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-20-x86_64/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "212947dce872f000ed1e1e0d29c1d701080131195318e289c148de1f3dde5963",
        }
      },
      "19" => {
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-19-x86_64/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "2c318dbf6bd224eeb74819904d578e96eb3481b7330cc92453365a4bc865b2bc",
        }
      },
      "18" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-18-i386/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "dc95676262f268d70985ad6a30fa21d8e1ea000bc612e0ddbf22c577acbb1054",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-18-x86_64/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "ed6409d2bafe48c8d66113f0cd4db8d110834e102dc3c2cb72983e0c4923e08d",
        }
      },
      "17" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-17-i386/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "b2170a17003d58b1fa895c6f846197dd3c6db259f3bad316211db5a212d43295",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.3/fedora/fedora-17-x86_64/",
          "package" => "pgdg-fedora93-9.3-1.noarch.rpm",
          "checksum" => "59c5bd5035c86c2a643da41c88f05a653630f8ae370b065882612a0101e2da44",
        }
      }
    }
  },
  "9.2" => {
    "centos" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/",
          "package" => "pgdg-centos92-9.2-7.noarch.rpm",
          "checksum" => "708b323e4fa09a50dfe6f3d8af5ad115f3059d1dc80ddc4cba7f1f8fb514276d",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/",
          "package" => "pgdg-centos92-9.2-7.noarch.rpm",
          "checksum" => "6f71489d6684957ecb610eb7ca3abb60f5974f2906761f97837c2d3148e08f64",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/",
          "package" => "pgdg-centos92-9.2-7.noarch.rpm",
          "checksum" => "e3d4c6e78b480c10232944b05571caefe16cc0810880d5488ab41feb69d29b33",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/",
          "package" => "pgdg-centos92-9.2-7.noarch.rpm",
          "checksum" => "be8127ae5c7330da06f102e8cc8135c0c38d8ddd87b2f79ed5332868018ee615",
        }
      }
    },
    "redhat" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "13414677077fbd5579f25df575f6d7506d2e1099e41d4ff09dba8456b1ab1472",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "6666a97839565f88cdc82370e668c6a4e03a5afa1fe67d8d1d84fc07f01b9b3d",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "4e52842e69e81bea167cea1be011e738fa405870fb1a30c7f82857d67d9d5d5b",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "797a64b24f3acc191487b2f976d0e25c29f783c82f899a650c1bc20d05c5fdab",
        }
      }
    },
    "oracle" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "13414677077fbd5579f25df575f6d7506d2e1099e41d4ff09dba8456b1ab1472",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "6666a97839565f88cdc82370e668c6a4e03a5afa1fe67d8d1d84fc07f01b9b3d",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "4e52842e69e81bea167cea1be011e738fa405870fb1a30c7f82857d67d9d5d5b",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/",
          "package" => "pgdg-redhat92-9.2-7.noarch.rpm",
          "checksum" => "797a64b24f3acc191487b2f976d0e25c29f783c82f899a650c1bc20d05c5fdab",
        }
      }
    },
    "scientific" => {
      "6" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/",
          "package" => "pgdg-sl92-9.2-8.noarch.rpm",
          "checksum" => "064e610c65c0891eeb3a1a3e7c2d9f3a1653e44259e5d16c0d4bce3df81bc0b3",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/",
          "package" => "pgdg-sl92-9.2-8.noarch.rpm",
          "checksum" => "566eb8e7e6115f1ea122b570bc37ef21c548a259dcb32933689b1a902ce95504",
        }
      },
      "5" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/",
          "package" => "pgdg-sl92-9.2-8.noarch.rpm",
          "checksum" => "8e87db32504d8fa6961d444800d57a2f3b1a9931ad82a754b8ab1e6b07f6f8b1",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/",
          "package" => "pgdg-sl92-9.2-8.noarch.rpm",
          "checksum" => "fd3c9bf36b9bf06e45fc8c969725af4e16a8a6f1f25daf625835021f8981eb1b",
        }
      }
    },
    "fedora" => {
      "19" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-19-i386/",
          "package" => "pgdg-fedora92-9.2-6.noarch.rpm",
          "checksum" => "e961a57041310b933042d6c51f9aa34a3d6728ddcd91983fa133aec9ea166d97",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-19-x86_64/",
          "package" => "pgdg-fedora92-9.2-6.noarch.rpm",
          "checksum" => "40465765d5634201efb86e57ea02aba343d929aa76882e19dfd8902c7400623d",
        }
      },
      "18" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-18-i386/",
          "package" => "pgdg-fedora92-9.2-6.noarch.rpm",
          "checksum" => "f28d51366442e9f1d7451bbadf8aa8da8cda43b63eb6f541ffc62b367fd6da04",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-18-x86_64/",
          "package" => "pgdg-fedora92-9.2-6.noarch.rpm",
          "checksum" => "8b327db55f1ddae34c2011dfdd359c42a15419c0ae2d49e8ba4da0c7f2d17676",
        }
      },
      "17" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-17-i386/",
          "package" => "pgdg-fedora92-9.2-6.noarch.rpm",
          "checksum" => "ec501ed065d5d0dc22886bd7f100075b8ebda3d648df79475ae10dc15882b8a4",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-17-x86_64/",
          "package" => "pgdg-fedora92-9.2-5.noarch.rpm",
          "checksum" => "0abeeefb1496622c04ff52435e0a39c7d951d795e06b18e345d22c0873a84a62",
        }
      },
      "16" => {
        "i386" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-16-i386/",
          "package" => "pgdg-fedora92-9.2-5.noarch.rpm",
          "checksum" => "523c0812fc3241ce6d2f86ca707f514ee02a778bb246f021e0226527ca6a5b5e",
        },
        "x86_64" => {
          "url" => "http://yum.postgresql.org/9.2/fedora/fedora-16-x86_64/",
          "package" => "pgdg-fedora92-9.2-5.noarch.rpm",
          "checksum" => "6980518fd8d505a773117e910366cf83a04257635238a432e47f624649060fb7",
        }
      }
    }
  }
}
