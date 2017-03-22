#
# Cookbook Name:: postgresql
# Resource:: user
#

actions :create, :update, :drop

default_action :create

attribute :name,               kind_of: String, name_attribute: true
attribute :superuser,          kind_of: [TrueClass, FalseClass], default: false
attribute :createdb,           kind_of: [TrueClass, FalseClass], default: false
attribute :createrole,         kind_of: [TrueClass, FalseClass], default: false
attribute :inherit,            kind_of: [TrueClass, FalseClass], default: true
attribute :replication,        kind_of: [TrueClass, FalseClass], default: false
attribute :login,              kind_of: [TrueClass, FalseClass], default: true
attribute :password,           kind_of: String
attribute :encrypted_password, kind_of: String

attr_accessor :exists
