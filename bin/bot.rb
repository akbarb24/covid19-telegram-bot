require 'telegram/bot'

require './lib/message_responder'
require './lib/app_configurator'
require './lib/notification_sender'

config = AppConfigurator.new
config.configure

token = config.get_token
logger = config.get_logger
pin = config.get_pin

logger.debug 'Starting telegram bot'

Telegram::Bot::Client.run(token) do |bot|
  notif_options = {
    bot: bot, 
    url: 'https://indonesia-covid-19.mathdro.id/api'
  }
  NotificationSender.new(notif_options).run
  
  bot.listen do |message|
    options = {bot: bot, message: message, pin: pin}

    logger.debug "@#{message.from.username}: #{message.text}" 
    MessageResponder.new(options).respond
  end
end