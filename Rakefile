require 'yaml'
require 'pry'
require 'sequel'
require 'logger'

SETTINGS = YAML.load_file('./settings/database.yml')

setup_postgres = lambda do |env|
  if SETTINGS[env.to_sym]

    db_default = SETTINGS[env.to_sym][:db_default]
    db_sensitive = SETTINGS[env.to_sym][:db_sensitive]
    sh "psql -U postgres -c \"CREATE USER #{db_default[:user]} PASSWORD '#{db_default[:password]}'\""
    sh "psql -U postgres -c \"CREATE USER #{db_sensitive[:user]} PASSWORD '#{db_sensitive[:password]}'\""
    sh "createdb -U postgres -O #{db_default[:user]} #{db_default[:user]}"
    sh "psql -U postgres -c \"CREATE EXTENSION citext\" #{db_default[:database]}"

  else
    puts("Please add environment \"#{env}\" to settings/database.yml")
  end
end

unset_postgres = lambda do |env|
  if SETTINGS[env.to_sym]

    db_default = SETTINGS[env.to_sym][:db_default]
    db_sensitive = SETTINGS[env.to_sym][:db_sensitive]
    sh "dropdb -U postgres #{db_default[:database]}"
    sh "dropuser -U postgres #{db_default[:user]}"
    sh "dropuser -U postgres #{db_sensitive[:user]}"

  else
    puts("Please add environment \"#{env}\" to settings/database.yml")
  end
end

migrate = lambda do |env, version|
  Sequel.extension :migration
  Sequel.connect(SETTINGS[env.to_sym][:db_default]) do |db|
    db.loggers << Logger.new($stdout)
    Sequel::Migrator.run(db, './migrate', target: version)
  end
end

migrate_sensitive = lambda do |env, version|
  Sequel.extension :migration
  Sequel.connect(SETTINGS[env.to_sym][:db_sensitive]) do |db|
    db.loggers << Logger.new($stdout)
    Sequel::Migrator.run(db, './migrate/migrate_password', table: 'schema_info_password', target: version)
  end
end

# run

desc 'Run the app with puma'
task :run do
  sh 'puma -e production config.ru'
end

# Migrate

# Database

namespace :db do

  desc 'Setup database PostgreSQL'
  task :set, [:env] do |t, args|
    setup_postgres.call(args[:env])
  end

  desc 'Unset database PostgreSQL'
  task :unset, [:env] do |t, args|
    unset_postgres.call(args[:env])
  end

  desc 'Database migration UP'
  task :migrate, [:env, :version] do |t, args|
    version = args[:version] ? args[:version].to_i : nil
    migrate.call(args[:env], version)
  end

  desc 'Database sensetive migration UP'
  task :migrate_sensitive, [:env, :version] do |t, args|
    version = args[:version] ? args[:version].to_i : nil
    migrate_sensitive.call(args[:env], version)
  end
end


# Shell
pry = proc do |env|
  ENV['RACK_ENV'] = env
  trap('INT', 'IGNORE')
  sh 'pry -r ./models.rb'
end
namespace :shell do
  desc 'Run pry (ENV: test, production, development)'
  task :pry, [:env] do |t, args|
    env = %w[test production development].include?(args[:env]) ? args[:env] : nil
    if env
      pry.call(env)
    else
      puts('Wrong env param')
    end
  end
end


# Specs

spec = proc do |pattern|
  sh "#{FileUtils::RUBY} -e 'ARGV.each{|f| require f}' #{pattern}"
end
namespace :spec do
  desc "Run all specs"
  task :default => [:model_spec, :web_spec]

  desc "Run model specs"
  task :model_spec do
    spec.call('./spec/model/*_spec.rb')
  end

  desc "Run web specs"
  task :web_spec do
    spec.call('./spec/web/*_spec.rb')
  end
end