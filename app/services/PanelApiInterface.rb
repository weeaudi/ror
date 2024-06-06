# app/services/panel_api_interface.rb
require 'net/http'
require 'json'

class PanelApiInterface
  API_BASE_URL = 'https://panel.inflames.cc/api/application'.freeze

  def self.find(email: nil, user_id: nil, name: nil, id: nil, identifier: nil, api_key:)
    raise ArgumentError, 'API key is required.' if api_key.blank?

    if email
      find_user_by_email(email, api_key)
    elsif user_id || name || id || identifier
      find_server(user_id, name, id, identifier, api_key)
    else
      raise ArgumentError, 'At least one parameter must be provided.'
    end
  end

  def self.find_all_servers(email:, api_key:)
    user = find(email: email, api_key: api_key)
    return [] unless user # Return empty array if user not found


    user_id = user['data'][0]['attributes']['id']
    find(user_id: user_id, api_key: api_key)
  end

  private

  def self.find_user_by_email(email, api_key)
    url = URI("#{API_BASE_URL}/users/?filter[email]=#{email}")
    make_api_call(url, api_key)
  end

  def self.find_server(user_id, name, id, identifier, api_key)
    user_id = user_id.to_i if user_id
    id = id.to_i if id
    query_params = { 'user' => user_id, 'name' => name, 'id' => id, 'identifier' => identifier }
    query_params.compact!
    if query_params.empty?
      raise ArgumentError, 'At least one parameter must be provided.'
    end
    url = URI("#{API_BASE_URL}/servers")
    servers = make_api_call(url, api_key)
    return [] unless servers # Return empty array if no servers are returned
    servers['data'].select do |server|
      query_params.all? { |key, value| server['attributes'][key] == value }
    end
  end

  def self.make_api_call(url, api_key)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{api_key}"

    response = http.request(request)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.error("JSON parsing error: #{e.message}")
    {}
  rescue StandardError => e
    Rails.logger.error("HTTP request error: #{e.message}")
    {}
  end
end
