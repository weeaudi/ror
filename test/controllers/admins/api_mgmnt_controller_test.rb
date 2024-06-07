# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admins::ApiMgmntController, type: :controller do
  describe 'GET #new' do
    before do
      user = FactoryBot.create(:user)
      sign_in user
    end

    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  # Add more tests for other actions here
end
