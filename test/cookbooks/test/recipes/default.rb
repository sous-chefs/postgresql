# frozen_string_literal: true
apt_update 'update'

include_recipe 'postgresql::default'
