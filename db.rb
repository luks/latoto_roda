require_relative '.env.rb'

require 'sequel'
require 'yaml'

DB_SETTINGS = YAML.load_file('settings/database.yml')
database = DB_SETTINGS[ENV['RACK_ENV'].to_sym][:db_default]
DB = Sequel.connect(database)
DB.extension :freeze_datasets
DB.extension :date_arithmetic

