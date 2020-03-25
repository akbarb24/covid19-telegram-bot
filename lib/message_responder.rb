require './models/user'
require './models/case'
require './lib/message_sender'

class MessageResponder
  attr_reader :pin
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  
  $broadcast_message = 'OK'
  $brodcast_mode = false
  
  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @pin = options[:pin]
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

    on /^\/subscribe/ do 
      subscribe
      answer_with_subsribed
    end

    on /^\/unsubs/ do
      handle_unsubs
    end

    on /broadcast:/ do
      handle_brodcast_command
    end

    on /\d+/ do
      puts $brodcast_mode
    
      handle_brodcast_execute message.text
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

  def handle_brodcast_command
    $broadcast_message = message.text.split(':')[1]
    $brodcast_mode = true

    answer_with_message 'Please, tell me the PIN'
  end

  def handle_brodcast_execute(pin_input)
    puts $brodcast_mode

    if $brodcast_mode
      puts pin

      if pin_input == pin.to_s
        send_broadcast
        $brodcast_mode = false
      else
        answer_with_message 'Auth failed'
      end
    else
      answer_with_message pin_input
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

  def handle_subscribe
    subscribe
    answer_with_subsribed
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

  def answer_with_subsribed
    answer_with_message I18n.t('subscribe_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_help_message
    answer_with_message I18n.t('help_message')
  end

  def answer_with_update
    case_data = Case.first
    
    unless case_data.nil?
      text = I18n.t('update_message')
      text = text.gsub('**last_update**', case_data.updated_at.strftime("%Y-%m-%d %H:%M:%S"))
      text = text.gsub('**infected**', case_data.infected.to_s)
      text = text.gsub('**active**', case_data.active.to_s)
      text = text.gsub('**recovered**', case_data.recovered.to_s)
      text = text.gsub('**death**', case_data.death.to_s)
      text = text.gsub('**url**', 'indonesia-covid-19.mathdro.id')
      answer_with_message text
    else 
      answer_with_message 'Maaf data belum dapat ditampilkan. Silahkan tunggu beberapa menit lagi. 🙏🏻'
    end
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, userid: message.chat.id, username: message.chat.username, text: text).send
  end

  def send_broadcast
    all_subscribes = User.where(is_subscribe: true)

    unless all_subscribes.nil?
      all_subscribes.each do |subs|
        MessageSender.new(bot: bot, userid: subs.userid, username: subs.username, text: $broadcast_message).send
      end
    end
  end
end
