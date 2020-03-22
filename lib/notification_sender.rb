require 'date'
require 'rufus-scheduler'
require './models/case'
require './lib/datasource_consumer'
require './lib/app_configurator'

class NotificationSender
  attr_reader :bot
  attr_reader :schedule
  attr_reader :datasource
  attr_reader :logger
  
  def initialize(options)
    @bot = options[:bot]
    @schedule = Rufus::Scheduler.new
    @datasource = DataSourceConsumer.new(options[:url])
    @logger = AppConfigurator.new.get_logger
  end

  def run
    scheduled_job
  end

  private

  def scheduled_job
    schedule.every '1m' do 
      if check_data?
        subscribers = User.where(is_subscribe: true)

        unless subscribers.nil?
          subscribers.each do |subs|
            send_message(subs)
          end
        end
      end
    end 
  end

  def check_data?
    logger.debug "Check data source"

    data_source = datasource.fetch_data_national
    exist_cases_data = Case.first

    if exist_cases_data.nil?
      logger.debug "Create new Case data"

      new_cases_data(data_source).save
    else
      unless compare_data?(exist_cases_data, new_cases_data(data_source))
        Case.update(exist_cases_data.id, new_cases_data(data_source))

        return true
      end
    end

    return false
  end

  def new_cases_data(data_source)
    Case.to_object(data_source)
  end

  def compare_data?(new_data, old_data)
    return false if new_data.infected != old_data.infected
    return false if new_data.active != old_data.active
    return false if new_data.recovered != old_data.recovered
    return false if new_data.death != old_data.death

    return true
  end

  def send_message(user)
    text = I18n.t('update_message')
    MessageSender.new(bot: bot, userid: user.userid, username: user.username, text: text).send
  end
end