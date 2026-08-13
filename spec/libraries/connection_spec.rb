require 'spec_helper'
require_relative '../../libraries/sql/_connection'

# Regression test for https://github.com/sous-chefs/postgresql/issues/833
#
# Under Chef 19 packaged as a Habitat package, the linker is started with a
# scoped LD_LIBRARY_PATH and `-z nodefaultlib`, so the `pg` gem's compiled
# `pg_ext.so` cannot find `libpq.so.5` at runtime even when it is installed,
# because nothing tells the linker where to look besides the default/system
# paths. Baking an rpath for the postgres lib dir into the gem build options
# lets `pg_ext.so` locate `libpq.so.5` regardless of the caller's
# LD_LIBRARY_PATH.
RSpec.describe PostgreSQL::Cookbook::SqlHelpers::Connection do
  subject(:helper) do
    Class.new do
      include PostgreSQL::Cookbook::SqlHelpers::Connection
    end.new
  end

  describe '#pg_gem_build_options' do
    before do
      allow(helper).to receive(:installed_postgresql_major_version).and_return('16')
      allow(helper).to receive(:installed_postgresql_package_source).and_return(:repo)
    end

    context 'on debian' do
      before { allow(helper).to receive(:node).and_return('platform_family' => 'debian') }

      it 'bakes an rpath for libpq into the build options so pg_ext.so can find it at runtime' do
        expect(helper.send(:pg_gem_build_options)).to include('-Wl,-rpath,/usr/include/postgresql')
      end
    end

    context 'on rhel' do
      before { allow(helper).to receive(:node).and_return('platform_family' => 'rhel') }

      it 'bakes an rpath for libpq into the build options so pg_ext.so can find it at runtime' do
        expect(helper.send(:pg_gem_build_options)).to include('-Wl,-rpath,/usr/pgsql-16/lib')
      end
    end
  end
end
