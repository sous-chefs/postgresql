# some older linux distributions have expired certificate bundles
# for pgdg repositories. Upgrading this package before trying to
# install postgresql is necessary.
package 'ca-certificates' do
  action :upgrade
end
