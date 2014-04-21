execute :fix_locale do
  command 'export LANGUAGE=en_US.UTF-8'
  command 'export LANG=en_US.UTF-8'
  command 'export LC_ALL=en_US.UTF-8'
  command 'locale-gen en_US.UTF-8'
  command 'sudo dpkg-reconfigure locales'
end
