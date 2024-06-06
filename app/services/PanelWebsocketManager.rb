require 'net/http'
require 'uri'
require 'json'

class PanelWebsocketManager
  @connections = {}

  def self.connect_websocket(id)
    puts "Starting websocket connection"
    server = fetch_server(id)
    if server
      server_uuid = server['attributes']['uuid']
      server_identifier = server['attributes']['identifier']
      setup_websocket_connection(server_uuid, server_identifier, id)
    else
      not_found(message: "Server not found!")
    end
  end

  def self.setup_websocket_connection(server_uuid, server_identifier, server_id)
    url = "wss://bonsai.inflames.cc/api/servers/#{server_uuid}/ws"
    headers = { 'Origin' => 'https://panel.inflames.cc' }

    token = generate_token(server_identifier)

    ws = WebSocket::Client::Simple.connect(url, headers: headers)
    @connections[server_id] = ws

    ws.on :open do
      puts "Websocket open"
      auth_message = { event: 'auth', args: [token] }.to_json
      logs_message = { event: 'send logs', args: [] }.to_json
      ws.send(auth_message)
      puts "Websocket auth sent"
      puts auth_message
      ws.send(logs_message)
    end

    ws.on :message do |msg|
      data = JSON.parse(msg.data)
      if data['event'] == 'console output'
        ActionCable.server.broadcast "console_channel_#{server_uuid}", {event: "RC", args: [data['args'].first]}.to_json
      elsif data['event'] == 'jwt error'
        ws.close
      elsif data['event'] == 'stats'
        ActionCable.server.broadcast "console_channel_#{server_uuid}", {event: "RS", args: [data['args'].first]}.to_json
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
      command_json = {event: 'send command', args: [command]}.to_json
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
    servers = PanelApiInterface.find(id: id, api_key: Rails.application.credentials.dig(:UsSe_R))
    servers.first
  end

  def self.generate_token(server_identifier)
    # API URL with the server identifier
    url = URI("https://panel.inflames.cc/api/client/servers/#{server_identifier}/websocket")

    # Set up the HTTP request with the bearer token
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bearer #{Rails.application.credentials.dig(:master_client_key)}"
    request["Content-Type"] = "application/json"

    # Perform the HTTP request
    response = http.request(request)

    # Check if the request was successful
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      puts data
      token = data.dig("data", "token")
      puts token
      if token
        return token
      else
        raise "Token not found in response: #{response.body}"
      end
    else
      raise "Failed to fetch token: #{response.message} (#{response.code})"
    end
  rescue => e
    Rails.logger.error "Error generating token: #{e.message}"
    raise e
  end
end
