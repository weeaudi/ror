# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class PanelWebsocketManager
  @connections = {}

  def self.connect_websocket(id)
    Rails.logger.debug 'Starting websocket connection'
    server = fetch_server(id)
    if server
      server_uuid = server['attributes']['uuid']
      server_identifier = server['attributes']['identifier']
      setup_websocket_connection(server_uuid, server_identifier, id)
    else
      not_found(message: 'Server not found!')
    end
  end

  def self.setup_websocket_connection(server_uuid, server_identifier, server_id)
    url = "wss://bonsai.inflames.cc/api/servers/#{server_uuid}/ws"
    headers = { 'Origin' => 'https://panel.inflames.cc' }

    token = generate_token(server_identifier)

    ws = WebSocket::Client::Simple.connect(url, headers:)
    @connections[server_id] = ws

    ws.on :open do
      Rails.logger.debug 'Websocket open'
      auth_message = { event: 'auth', args: [token] }.to_json
      logs_message = { event: 'send logs', args: [] }.to_json
      ws.send(auth_message)
      Rails.logger.debug 'Websocket auth sent'
      Rails.logger.debug auth_message
      ws.send(logs_message)
    end

    ws.on :message do |msg|
      data = JSON.parse(msg.data)
      case data['event']
      when 'console output'
        ActionCable.server.broadcast "console_channel_#{server_uuid}",
                                     { event: 'RC', args: [data['args'].first] }.to_json
      when 'jwt error'
        ws.close
      when 'stats'
        ActionCable.server.broadcast "console_channel_#{server_uuid}",
                                     { event: 'RS', args: [data['args'].first] }.to_json
      end
    end

    ws.on :close do |e|
      Rails.logger.info "Connection closed: #{e}"
    end

    ws.on :error do |e|
      Rails.logger.error "websocket Error: #{e}"
    end
  end

  def self.send_command(command, server_id)
    if @connections[server_id]
      command_json = { event: 'send command', args: [command] }.to_json
      @connections[server_id].send(command_json)
    else
      Rails.logger.warn "No active WebSocket connection found for server ID: #{server_id}"
    end
  end

  def self.disconnect_websocket(server_id)
    if @connections[server_id]
      @connections[server_id].close
      @connections.delete(server_id)
    else
      Rails.logger.warn "No active WebSocket connection found for server ID: #{server_id}"
    end
  end

  def self.fetch_server(id)
    servers = PanelApiInterface.find(id:, api_key: Rails.application.credentials[:UsSe_R])
    servers.first
  end

  def self.generate_token(server_identifier)
    # API URL with the server identifier
    url = URI("https://panel.inflames.cc/api/client/servers/#{server_identifier}/websocket")

    # Set up the HTTP request with the bearer token
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request['Authorization'] = "Bearer #{Rails.application.credentials[:master_client_key]}"
    request['Content-Type'] = 'application/json'

    # Perform the HTTP request
    response = http.request(request)

    # Check if the request was successful
    raise "Failed to fetch token: #{response.message} (#{response.code})" unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    Rails.logger.debug data
    token = data.dig('data', 'token')
    Rails.logger.debug token
    return token if token

    raise "Token not found in response: #{response.body}"
  rescue StandardError => e
    Rails.logger.error "Error generating token: #{e.message}"
    raise e
  end
end
