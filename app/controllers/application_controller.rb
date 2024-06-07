# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def not_found(message: 'Not Found')
    Rails.logger.debug message
    render json: { error: message }, status: :not_found
  end

  def authenticate_admin!
    Rails.logger.debug current_user
    Rails.logger.debug current_user.admin? if current_user
    redirect_to root_path unless current_user&.admin?
  end

  def authenticate_api_token!(area, token, permission)
    area_record = Area.find_by(name: area)
    token_record = ApiToken.find_by(token:)

    if area_record.nil?
      Rails.logger.debug 'Area not found'
      render json: { "error": 'Area not found!' }
    elsif token_record.nil?
      Rails.logger.debug 'Token not found'
      render json: { "error": 'Token not found' }
    else
      token_area = token.api_token_areas.find_by(area_id: area.id)
      render json: { "error": 'Internal server error!' }, code: 500 unless token_area
      return true if token_area.permission <= permission

      render json: { "error": "Token doesn't have the required permission!" }
    end
  end
end
