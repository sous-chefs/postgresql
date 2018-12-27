require 'spec_helper'

describe 'postgresql_server_install' do
  step_into :server_install

  context 'default ident conf' do
    recipe do
      postgresql_server_install 'test' do
        version '10'
      end
    end

    context 'on ubuntu' do
      platform 'ubuntu'

      it do
        is_expected.to install_postgresql_server_install('test').with(ident_file: '/etc/postgresql/10/main/pg_ident.conf')
      end
    end

    context 'on fedora' do
      platform 'fedora'

      it do
        is_expected.to install_postgresql_server_install('test').with(ident_file: '/var/lib/pgsql/10/data/pg_ident.conf')
      end
    end
  end

  context 'default hba conf' do
    recipe do
      postgresql_server_install 'test' do
        version '10'
      end
    end

    context 'on ubuntu' do
      platform 'ubuntu'

      it do
        is_expected.to install_postgresql_server_install('test').with(hba_file: '/etc/postgresql/10/main/pg_hba.conf')
      end
    end

    context 'on fedora' do
      platform 'fedora'

      it do
        is_expected.to install_postgresql_server_install('test').with(hba_file: '/var/lib/pgsql/10/data/pg_hba.conf')
      end
    end
  end

  # Also another ChefSpec bug
  # context 'install the correct package' do
  #   recipe do
  #     postgresql_server_install 'test' do
  #       version '10'
  #       action :install
  #     end
  #   end

  #   context 'on ubuntu' do
  #     platform 'ubuntu'

  #     it do
  #       expect(chef_run).to install_package('postgresql-10')
  #     end
  #   end

  #   context 'on fedora' do
  #     platform 'fedora'

  #     it do
  #       expect(chef_run).to install_package('postgresql-10-server')
  #     end
  #   end
  # end

  # Commented out for now, think I found a ChefSpec Bug
  # context 'signal the correct service' do
  #   recipe do
  #     postgresql_server_install 'test' do
  #       version '10'
  #       action :create
  #     end
  #   end

  #   context 'on ubuntu' do
  #     platform 'ubuntu'

  #     it do
  #       expect(chef_run).to enable_service('postgresql').with(service_name: 'postgresql')
  #     end
  #   end

  #   context 'on fedora' do
  #     platform 'fedora'

  #     it do
  #       expect(chef_run).to start_service('postgresql').with(service_name: 'postgresql-10')
  #     end
  #   end
  # end
end
