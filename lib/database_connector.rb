require 'active_record'
require 'logger'
require 'erb'

class DatabaseConnector
  class << self
    def establish_connection
      ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      # configuration = YAML::load(IO.read(database_config_path))
      configuration = YAML.load(ERB.new(File.read(database_config_path)).result)

      ActiveRecord::Base.establish_connection(configuration)
    end

    private

    def active_record_logger_path
      'debug.log'
    end

    def database_config_path
      'config/database.yml'
    end
  end
end
