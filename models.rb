require_relative 'db'

if ENV['RACK_ENV'] == 'development'
  Sequel::Model.cache_associations = false
end

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :subclasses unless ENV['RACK_ENV'] == 'development'

# forme test
Sequel::Model.plugin :defaults_setter
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :forme
Sequel::Model.plugin :association_pks
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :subclasses
Sequel::Model.plugin :many_through_many
# /forme test

unless defined?(Unreloader)
  require 'rack/unreloader'
  Unreloader = Rack::Unreloader.new(:reload=>false)
end

Unreloader.require('models'){|f| Sequel::Model.send(:camelize, File.basename(f).sub(/\.rb\z/, ''))}

if ENV['RACK_ENV'] == 'development'
  require 'logger'
  DB.loggers << Logger.new($stdout)
else
  Sequel::Model.freeze_descendents
  DB.freeze
end
