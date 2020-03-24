require './models/user'
require './models/case'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(userid: message.from.id, username: message.from.username)
  end

  def respond
    on /^\/start/ do
      handle_start
    end

    on /^\/help/ do
      handle_help
    end

    on /^\/update/ do
      handle_update
    end

    on /^\/unsubs/ do
      handle_unsubs
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
    answer_with_update
  end

  def handle_help
    answer_with_help_message
  end

  def handle_update
    answer_with_update
  end

  def handle_unsubs
    unsubscribe
    answer_with_farewell_message
  end

  def subscribe
    User.update(user.id, is_subscribe: true)
  end

  def unsubscribe
    User.update(user.id, is_subscribe: false)
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_help_message
    answer_with_message I18n.t('help_message')
  end

  def answer_with_update
    case_data = get_data
    
    unless case_data.nil?
      text = I18n.t('update_message')
      text = text.gsub('**last_update**', case_data.updated_at.strftime("%Y-%m-%d %H:%M:%S"))
      text = text.gsub('**infected**', case_data.infected.to_s)
      text = text.gsub('**active**', case_data.active.to_s)
      text = text.gsub('**recovered**', case_data.recovered.to_s)
      text = text.gsub('**death**', case_data.death.to_s)
      text = text.gsub('**url**', 'indonesia-covid-19.mathdro.id')
      answer_with_message text
    end
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, userid: message.chat.id, username: message.chat.username, text: text).send
  end

  def get_data
    Case.first
  end
end
