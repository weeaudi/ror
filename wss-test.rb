require 'websocket-client-simple'

# Define the WebSocket URL and any custom headers
url = 'wss://bonsai.inflames.cc/api/servers/fdaf0a00-45ee-4c40-88d7-f39b5089a8f8/ws'
headers = {
  'Origin' => 'https://panel.inflames.cc'
}

# Create a WebSocket client and connect
ws = WebSocket::Client::Simple.connect(url, headers:)

# Handle the open event
ws.on :open do
  puts 'Connected to the WebSocket server.'
end

# Handle the message event
ws.on :message do |msg|
  puts "Received message: #{msg.data}"
end

# Handle the close event
ws.on :close do |e|
  puts "Connection closed: #{e}"
end

# Handle the error event
ws.on :error do |e|
  puts "Error: #{e}"
end

# Create a separate thread to read input from the console and send messages
Thread.new do
  loop do
    message = gets.chomp
    ws.send message
  end
end

# Keep the main thread running to maintain the WebSocket connection
loop do
  sleep 1
end
