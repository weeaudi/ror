class ApiTokenManager

  def self.authenticate_api_token!(area, token, permission)
    area_record = Area.find_by_name(area)
    token_record = ApiToken.find_by_token(token)
  
    if area_record.nil?
      puts "Area not found"
      render json: {"error": "Area not found!"}
    elsif token_record.nil?
      puts "Token not found"
      render json: {"error": "Token not found"}
    else
      token_area = token_record.api_token_areas.find_by_area_id(area_record.id)
      render json: {"error": "Internal server error!"}, code: 500 unless token_area
      return if token_area.permission.to_i <= permission
      render json: {"error": "Token doesn't have the required permission!"}
    end
  end

end