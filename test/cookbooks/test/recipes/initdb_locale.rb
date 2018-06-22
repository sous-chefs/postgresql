postgresql_server_install 'Install' do
  version '10'
  initdb_locale 'en_GB.utf8'
  action [:install, :create]
end
