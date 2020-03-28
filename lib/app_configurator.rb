require 'logger'
require 'erb'

require './lib/database_connector'

class AppConfigurator
  def configure
    setup_i18n
    setup_database
  end

  def get_token
    YAML.load(ERB.new(File.read('config/secrets.yml')).result)['telegram_bot_token']
  end

  def get_logger
    megabyte = 1024 ** 2
    one_hundred_megabytes = megabyte * 100

    Logger.new("covid19bot.log", 5, one_hundred_megabytes)
  end

  def get_pin
    YAML.load(ERB.new(File.read('config/secrets.yml')).result)['pin_bot']
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.locale = :en
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end
end
