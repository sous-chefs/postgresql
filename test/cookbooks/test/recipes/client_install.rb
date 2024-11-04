# Import PostgreSQL GPG key
# execute 'import_pgdg_key' do
#   command 'rpm --import https://download.postgresql.org/pub/repos/yum/keys/RPM-GPG-KEY-PGDG'
#   not_if 'rpm -q gpg-pubkey-08b40d20-*'
# end

include_recipe 'test::dokken'

postgresql_install 'postgresql' do
  version node['test']['pg_ver']

  action %i(install_client)
end
