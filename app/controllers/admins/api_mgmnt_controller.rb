# app/controllers/admins/api_mgmnt_controller.rb
class Admins::ApiMgmntController < ApplicationController
  before_action :authenticate_admin!

  def new
    @api_token = ApiToken.new
    @areas = Area.all
    @api_token.api_token_areas.build # Build a new ApiTokenArea for each area
  end

  def create_api_token
    puts params
    @api_token = ApiToken.new(api_token_params)

    @api_token.token = 'ICWB_' + SecureRandom.hex(20)

    if @api_token.save
      flash[:notice] = 'API Token created successfully: ' + @api_token.token
      redirect_to admins_api_mgmnt_index_path
    else
      flash[:alert] = 'There was an error creating the API token.'
      render :new
    end
  end

  private

  def api_token_params
    params.require(:api_token).permit(:allowed_ips, api_token_areas_attributes: %i[area_id permission])
  end
end
