require 'spec_helper'

describe 'postgresql_server_conf' do
  step_into :postgresql_server_conf

  context 'default data dir' do
    recipe do
      postgresql_server_conf 'test' do
        version '10'
      end
    end

    context 'on ubuntu' do
      platform 'ubuntu'

      it do
        is_expected.to modify_postgresql_server_conf('test').with(data_directory: '/var/lib/postgresql/10/main')
      end
    end

    context 'on fedora' do
      platform 'fedora'

      it do
        is_expected.to modify_postgresql_server_conf('test').with(data_directory: '/var/lib/pgsql/10/data')
      end
    end
  end

  context 'default hba conf' do
    recipe do
      postgresql_server_conf 'test' do
        version '10'
      end
    end

    context 'on ubuntu' do
      platform 'ubuntu'

      it do
        is_expected.to modify_postgresql_server_conf('test').with(hba_file: '/etc/postgresql/10/main/pg_hba.conf')
      end
    end

    context 'on fedora' do
      platform 'fedora'

      it do
        is_expected.to modify_postgresql_server_conf('test').with(hba_file: '/var/lib/pgsql/10/data/pg_hba.conf')
      end
    end
  end
end
