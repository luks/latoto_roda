# run

desc 'Run the app with puma'
task :run do
  sh 'puma -e production config.ru'
end


# Migrate

migrate = lambda do |env, version|
  ENV['RACK_ENV'] = env
  require_relative 'db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout)
  Sequel::Migrator.apply(DB, 'migrate', version)
end


# Database

namespace :db do
  desc 'Setup database PostgreSQL'
  task :setup_postgres do
    sh 'psql -U postgres -c "CREATE USER latoto PASSWORD \'latoto\'"'
    sh 'psql -U postgres -c "CREATE USER latoto_password PASSWORD \'latoto\'"'
    sh 'createdb -U postgres -O latoto latoto'
    sh 'psql -U postgres -c "CREATE EXTENSION citext" latoto'
    $: << 'lib'
    require 'sequel'
    Sequel.extension :migration
    Sequel.postgres(:user=>'latoto', :password=>'latoto') do |db|
      Sequel::Migrator.run(db, './migrate')
    end
    Sequel.postgres('latoto', :user=>'latoto_password', :password=>'latoto') do |db|
      Sequel::Migrator.run(db, './migrate/migrate_password', :table=>'schema_info_password')
    end
  end

  desc 'Teardown database PostgreSQL'
  task :teardown_postgres do
    sh 'dropdb -U postgres latoto'
    sh 'dropuser -U postgres latoto'
    sh 'dropuser -U postgres latoto_password'
  end

  desc 'Switch database owner to latoto'
  task :switch_owner do
    require_relative 'db'
    require './sql/switch_postgres_owner'
    DB.extend SwitchPostgresOwner
    DB.switch_owner_to('latoto')
  end
  
  desc "Migrate test database to latest version"
  task :test_up do
    migrate.call('test', nil)
  end
  
  desc "Migrate test database all the way down"
  task :test_down do
    migrate.call('test', 0)
  end
  
  desc "Migrate test database all the way down and then back up"
  task :test_bounce do
    migrate.call('test', 0)
    Sequel::Migrator.apply(DB, 'latoto')
  end
  
  desc "Migrate development database to latest version"
  task :dev_up do
    migrate.call('development', nil)
  end
  
  desc "Migrate development database to all the way down"
  task :dev_down do
    migrate.call('development', 0)
  end
  
  desc "Migrate development database all the way down and then back up"
  task :dev_bounce do
    migrate.call('development', 0)
    Sequel::Migrator.apply(DB, 'latoto')
  end
  
  desc "Migrate production database to latest version"
  task :prod_up do
    migrate.call('production', nil)
  end
end

# Shell

irb = proc do |env|
  ENV['RACK_ENV'] = env
  trap('INT', "IGNORE")
  dir, base = File.split(FileUtils::RUBY)
  cmd = if base.sub!(/\Aruby/, 'irb')
    File.join(dir, base)
  else
    "#{FileUtils::RUBY} -S irb"
  end
  sh "#{cmd} -r ./models"
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
    elsexxx
      puts('Wrong env param')
    end
  end


  desc "Open irb shell in test mode"
  task :test_irb do
    irb.call('test')
  end

  desc "Open irb shell in development mode"
  task :dev_irb do
    irb.call('development')
  end

  desc "Open irb shell in production mode"
  task :prod_irb do
    irb.call('production')
  end
end


# Specs

spec = proc do |pattern|
  sh "#{FileUtils::RUBY} -e 'ARGV.each{|f| require f}' #{pattern}"
end

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
