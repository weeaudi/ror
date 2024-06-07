require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'GET #not_found' do
    it 'returns a 404 status' do
      get :not_found
      expect(response.status).to eq(404)
    end
  end

  # Add more tests for other actions here
end
