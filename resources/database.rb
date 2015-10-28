#
# Cookbook Name:: postgresql
# Resource:: database
#

actions :create, :drop

default_action :create

attribute :name,     kind_of: String, name_attribute: true
attribute :user,     kind_of: String, default: "postgres"
attribute :username, kind_of: String
attribute :host,     kind_of: String
attribute :port,     kind_of: Integer
attribute :encoding, kind_of: String, default: "UTF-8"
attribute :locale,   kind_of: String, default: "en_US.UTF-8"
attribute :template, kind_of: String, default: "template0"
attribute :owner,    kind_of: String

attr_accessor :exists
