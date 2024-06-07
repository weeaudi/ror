class AdminsController < ApplicationController
  before_action :authenticate_token

  require 'net/http'
  require 'uri'
  require 'json'

  def refresh
    uri = URI.parse('https://panel.inflames.cc/api/application/users')
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{Rails.application.credentials.dig(:UsSe_R)}"
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      users_data = JSON.parse(response.body)['data']
      users_data.each do |user_data|
        user_id = user_data['attributes']['id']
        user_email = user_data['attributes']['email']
        root_admin = user_data['attributes']['root_admin']

        user = User.find_by(email: user_email)
        next unless user

        user.update(admin: root_admin)
        user.update(id: user_id) unless user.id == user_id
        puts 'User: ' + user.id.to_s + '-' + user.email + ' updated!'
      end

      render json: { status: 'success', message: 'Admin statuses updated' }
    else
      render json: { status: 'error', message: 'Failed to fetch users from API ' + response.code }, status: :bad_request
    end
  rescue StandardError => e
    render json: { status: 'error', message: e.message }, status: :internal_server_error
  end

  private

  def authenticate_token
    area = 'area_name'
    token = params[:token]
    permission = required_permission
    ApiTokenManager.authenticate_api_token!('User Admin Refresh', 'ICWB_e2f9d2fcf0b2003b69d5a7a31d4072e242910498', 2)
  rescue StandardError => e
    render json: { error: e.message }, status: :unauthorized
  end

  def required_permission
    1
  end
end
