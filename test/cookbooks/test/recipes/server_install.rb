postgresql_repository 'install' do
  version '9.5'
end

postgresql_server_install 'package'
