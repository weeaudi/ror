# app/channels/console_channel.rb
class ConsoleChannel < ApplicationCable::Channel
  def subscribed
    logger.info 'Client subscribed to ConsoleChannel'
    @server_uuid = params[:server_uuid]
    @server_id = params[:server_id]

    unless @server_uuid && @server_id
      logger.error 'Missing server_uuid or server_id in subscription parameters'
      reject
      return
    end

    begin
      stream_from "console_channel_#{@server_uuid}"
      PanelWebsocketManager.connect_websocket(@server_id)
    rescue StandardError => e
      logger.error "Error connecting to WebSocket: #{e.message}"
      reject
    end
  end

  def command(data)
    puts "Received command: #{data}"
    PanelWebsocketManager.send_command(data['command'], @server_id)
  end

  def unsubscribed
    logger.info 'Client unsubscribed from ConsoleChannel'
    PanelWebsocketManager.disconnect_websocket(@server_id)
  end
end
