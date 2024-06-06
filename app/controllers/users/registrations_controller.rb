# app/controllers/users/registrations_controller.rb

require 'net/http'

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted? # Check if the user is successfully saved
=begin        
        panel_user_id = create_panel_account(resource)
        if panel_user_id
          resource.update_column(:id, panel_user_id)
        else
          resource.destroy
          puts @panel_error_message
          redirect_to new_user_registration_path and return
        end
=end
      end
    end
  end

  private

  def create_panel_account(user)
    api_key = Rails.application.credentials.dig(:Us_RW)
    url = URI("https://panel.inflames.cc/api/application/users")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'

    user_data = {
      email: user.email,
      username: "WebsiteUser" + user.id.to_s,
      first_name: "WebsiteUser" + user.id.to_s,
      last_name: "WebsiteUser" + user.id.to_s
    }

    request.body = user_data.to_json

    response = http.request(request)
    response_body = JSON.parse(response.body)

    puts response_body

    if response.is_a?(Net::HTTPSuccess)
      response_body['attributes']['id'] # Adjust based on the actual response structure
    else
      @panel_error_message = "Panel Account Creation Failed: #{response_body['error'] || response_body['message']}"
      nil
    end
  rescue StandardError => e
    @panel_error_message = "Panel Account Creation Failed: #{e.message}"
    nil
  end
end