default['postgresql']['wal_e'] = {
  packages: %w(
    python-setuptools
    python-dev
    lzop
    pv
    git
    libevent-dev
    daemontools
  ),
  pips: %w(
    gevent
    argparse
    boto
  ),
  git_version: 'v0.7.0',
  env_dir: '/etc/wal-e',
  aws_access_key: nil,
  aws_secret_key: nil,
  s3_bucket: nil,
  bkp_folder: node['hostname'] + '-pq-' + ( node['postgresql']['version'] || '-unknown' ).to_s,
  base_backup: {
    minute: '0',
    hour: '0',
    day: '*',
    month: '*',
    weekday: '1',
  },
  user: 'postgres',
  group: 'postgres',
}
