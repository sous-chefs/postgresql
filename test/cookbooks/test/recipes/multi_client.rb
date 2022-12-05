postgresql_install '13' do
  version '13'

  action :install_client
end

postgresql_install '15' do
  version '15'

  action :install_client
end
