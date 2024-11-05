postgresql_install '16' do
  version '16'

  action :install_client
end

postgresql_install '15' do
  version '15'

  action :install_client
end
