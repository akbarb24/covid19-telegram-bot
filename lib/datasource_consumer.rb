require 'faraday'

class DataSourceConsumer
  attr_reader :base_url

  def initialize(base_url)
    @base_url = base_url
  end

  def fetch_data_national
    response = Faraday.get(base_url)
    JSON.parse(response.body, symbolize_names: true)
  end

  def fetch_data_province
    response = Faraday.get(base_url + '/provinsi')
  end
end