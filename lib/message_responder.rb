require './models/user'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(userid: message.from.id)
  end

  def respond
    on /^\/start/ do
      handle_start
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def handle_start
    subscribe

    answer_with_greeting_message
  end

  def subscribe
    User.update(user.id, is_subscribe: true)
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, userid: message.chat.id, username: message.chat.username, text: text).send
  end
end
