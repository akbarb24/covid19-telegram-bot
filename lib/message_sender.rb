require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender
  attr_reader :bot
  attr_reader :text
  attr_reader :userid
  attr_reader :username
  attr_reader :answers
  attr_reader :logger

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @userid = options[:userid]
    @username = options[:username]
    @answers = options[:answers]
    @logger = AppConfigurator.new.get_logger
  end

  def send
    if reply_markup
      bot.api.send_message(chat_id: userid, text: text, reply_markup: reply_markup)
    else
      bot.api.send_message(chat_id: userid, text: text)
    end

    logger.debug "sending '#{text}' to #{username}"
  end

  private

  def reply_markup
    if answers
      ReplyMarkupFormatter.new(answers).get_markup
    end
  end
end
