# frozen_string_literal: true

# controller for managing servers
class ServersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_api_key

  def index
    email = current_user.email
    @servers = PanelApiInterface.find_all_servers(email:, api_key: @api_key)
  end

  def index_json
    email = current_user.email
    servers = PanelApiInterface.find_all_servers(email:, api_key: @api_key)
    render json: servers
  end

  def show
    server = fetch_server(params[:id])
    if server
      @server = server['attributes']
    else
      not_found(message: 'Server not found!')
    end
  end

  def show_json
    server = fetch_server(params[:id])
    if server
      render json: server['attributes']
    else
      not_found(message: 'Server not found!')
    end
  end

  def websocket_console
    server = fetch_server(params[:id])
    if server
      @server_uuid = server['attributes']['uuid']
      @server_id = server['attributes']['id']
      @token = generate_token
    else
      not_found(message: 'Server not found!')
    end
  end

  private

  def set_api_key
    @api_key = Rails.application.credentials[:UsSe_R]
  end

  def fetch_server(id)
    servers = PanelApiInterface.find(id:, api_key: @api_key)
    servers.first
  end

  def generate_token
    # Placeholder for token generation logic
    'your_generated_token'
  end

  def not_found(message:)
    render json: { error: message }, status: :not_found
  end
end
