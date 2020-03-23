require 'rubygems'
require 'bundler/setup'
require 'erb'
require 'pg'
require 'active_record'
require 'yaml'

namespace :db do

  desc 'Migrate the database'
  task :migrate do
    # connection_details = YAML::load(File.open('config/database.yml'))
    connection_details = YAML.load(ERB.new(File.read('config/database.yml')).result)
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::MigrationContext.new('db/migrate/').migrate
  end

  desc 'Create the database'
  task :create do
    # connection_details = YAML::load(File.open('config/database.yml'))\
    connection_details = YAML.load(ERB.new(File.read('config/database.yml')).result)
    admin_connection = connection_details.merge({'database'=> 'postgres',
                                                'schema_search_path'=> 'public'})

    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc 'Drop the database'
  task :drop do
    # connection_details = YAML::load(File.open('config/database.yml'))
    connection_details = YAML.load(ERB.new(File.read('config/database.yml')).result)
    admin_connection = connection_details.merge({'database'=> 'postgres',
                                                'schema_search_path'=> 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end
end
