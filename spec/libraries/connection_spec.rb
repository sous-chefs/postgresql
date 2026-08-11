require 'spec_helper'
require 'open3'
require 'rbconfig'
require_relative '../../libraries/sql/_connection'

RSpec.describe PostgreSQL::Cookbook::SqlHelpers::Connection do
  subject(:helper) do
    Class.new do
      include PostgreSQL::Cookbook::SqlHelpers::Connection

      attr_accessor :node
    end.new
  end

  let(:node) { { 'platform_family' => 'debian' } }

  before do
    helper.node = node
  end

  describe '#pg_gem_build_options' do
    before do
      allow(helper).to receive(:postgresql_devel_path).and_return('/usr/include/postgresql')
    end

    context 'when Chef runs from a Habitat package' do
      before do
        allow(RbConfig).to receive(:ruby).and_return('/hab/pkgs/core/ruby3_4/3.4.8/20260514054813/bin/ruby')
      end

      it 'allows RubyGems to select the binary pg gem with bundled libpq' do
        expect(helper.send(:pg_gem_build_options)).to be_nil
      end
    end

    context 'when Chef does not run from a Habitat package' do
      before do
        allow(RbConfig).to receive(:ruby).and_return('/opt/chef/embedded/bin/ruby')
      end

      it 'retains the source pg gem build options' do
        expect(helper.send(:pg_gem_build_options)).to eq(
          '--platform ruby -- --with-pg-include=/usr/include/postgresql --with-pg-lib=/usr/include/postgresql'
        )
      end
    end
  end

  describe '#install_pg_gem' do
    let(:declared_resources) { [] }
    let(:recording_resource) do
      Class.new do
        attr_reader :properties

        def initialize
          @properties = {}
        end

        %i(action compile_time options package_name version).each do |property|
          define_method(property) { |value| @properties[property] = value }
        end
      end
    end

    before do
      allow(RbConfig).to receive(:ruby).and_return('/hab/pkgs/core/ruby3_4/3.4.8/20260514054813/bin/ruby')
      allow(helper).to receive(:gem_installed?).with('pg').and_return(false)
      allow(helper).to receive(:installed_postgresql_package_source).and_return(:repo)
      allow(helper).to receive(:platform_family?).with('rhel').and_return(false)
      allow(helper).to receive(:postgresql_devel_pkg_name).and_return('libpq-dev')
      allow(helper).to receive(:declare_resource) do |type, name, &block|
        resource = recording_resource.new
        resource.instance_eval(&block)
        declared_resources << [type, name, resource.properties]
      end
    end

    it 'does not force the source pg gem under Habitat' do
      helper.send(:install_pg_gem)

      expect(declared_resources).to eq(
        [
          [:build_essential, 'Build Essential', { compile_time: true }],
          [:package, 'libpq-dev', { compile_time: true }],
          [:chef_gem, 'pg', { version: '~> 1.4', compile_time: true }],
        ]
      )
    end

    context 'when a prior converge installed an unusable pg gem under Habitat' do
      let(:failed_status) { instance_double(Process::Status, success?: false) }

      before do
        allow(helper).to receive(:gem_installed?).with('pg').and_return(true)
        allow(Open3).to receive(:capture3).and_return(['', '', failed_status])
      end

      it 'removes the incompatible gem before installing the platform gem' do
        helper.send(:install_pg_gem)

        expect(declared_resources).to eq(
          [
            [:chef_gem, 'Remove incompatible pg gem', { package_name: 'pg', compile_time: true, action: :remove }],
            [:build_essential, 'Build Essential', { compile_time: true }],
            [:package, 'libpq-dev', { compile_time: true }],
            [:chef_gem, 'pg', { version: '~> 1.4', compile_time: true }],
          ]
        )
      end
    end

    context 'when a healthy platform pg gem is already installed under Habitat' do
      let(:successful_status) { instance_double(Process::Status, success?: true) }

      before do
        allow(helper).to receive(:gem_installed?).with('pg').and_return(true)
        allow(Open3).to receive(:capture3).and_return(['', '', successful_status])
      end

      it 'does not disturb the installed gem' do
        helper.send(:install_pg_gem)

        expect(declared_resources).to be_empty
      end
    end

    context 'when pg is already installed outside Habitat' do
      before do
        allow(RbConfig).to receive(:ruby).and_return('/opt/chef/embedded/bin/ruby')
        allow(helper).to receive(:gem_installed?).with('pg').and_return(true)
      end

      it 'retains the existing presence-only behavior' do
        expect(Open3).not_to receive(:capture3)

        helper.send(:install_pg_gem)

        expect(declared_resources).to be_empty
      end
    end
  end
end
