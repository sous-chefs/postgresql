property :version, String, default: '10'
property :minor_version, String, default: '10-1'

action :add do
  p_version = node['platform_version'].to_i
  p_family = node['platform_family']
  p_short = node['platform']

  case node['platform_family']

  when 'rhel'
    remote_file "#{Chef::Config[:file_cache_path]}/pgdg.rpm" do
      source "https://download.postgresql.org/pub/repos/yum/#{new_resource.version}/redhat/#{p_family}-#{p_version}-x86_64/pgdg-#{p_short}#{new_resource.version}-#{new_resource.minor_version}.noarch.rpm"
      action :create
    end

    yum_package "#{Chef::Config[:file_cache_path]}/pgdg.rpm"
  when 'debian'
  #   apt_repository 'name' do
  #    uri                   http://apt.postgresql.org/pub/repos/apt/ YOUR_UBUNTU_VERSION_HERE-pgdg main
  #    distribution          String
  #    components            Array
  #    arch                  String
  #    trusted               TrueClass, FalseClass
  #    deb_src               TrueClass, FalseClass
  #    keyserver             String
  #    key                   String, Array
  #    key_proxy             String
  #    cookbook              String
  #    cache_rebuild         TrueClass, FalseClass
  #    sensitive             TrueClass, FalseClass
  #   end
  #
  #   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  #     sudo apt-key add -


    apt_update 'update'
  end
end



# stretch, jessie, wheezy,zesty
