# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  include Rails.application.routes.url_helpers
  dummy_panel_user_id = rand(1...1000)
  describe 'POST #create' do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      allow_any_instance_of(Users::RegistrationsController)
        .to receive(:create_panel_account)
        .and_return(dummy_panel_user_id)
    end

    it 'creates a new user and adds an account to the external panel' do
      post :create, params: { user: { email: 'testuser@example.com', password: 'password' } }
      expect(response).to redirect_to(root_path(assigns(:user)))
      expect(assigns(:user).id).to eq(dummy_panel_user_id)
    end
  end
end
