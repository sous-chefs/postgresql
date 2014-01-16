# this is for archiving
# default['postgresql']['streaming']['shared_backup'] = '/share/psql/backup'
default['postgresql']['shared_archive'] = '/share/psql/archive'
default['postgresql']['streaming'] = {
  master: {
  # default config for streaming.
    config: {
      wal_level: "hot_standby",
      listen_addresses: '*',
      max_wal_senders: 5,
      wal_keep_segments: 32,
      archive_mode: true,
      archive_command: "test ! -f #{node['postgresql']['shared_archive']}/%f && cp %p #{node['postgresql']['shared_archive']}/%f",
    },
  # pg_hba additions
    pg_hba: [ {:type => 'host', :db => 'replication', :user => 'all', :addr => '0.0.0.0/0', :method => 'trust'} ]
  },
  slave: {
    config: {
      hot_standby: true,
    },
  },
}