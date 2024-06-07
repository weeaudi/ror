require 'spec/rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  describe "POST #create" do
    before do
      allow_any_instance_of(Users::RegistrationsController)
        .to receive(:create_panel_account)
        .and_return('dummy_panel_user_id')
    end

    it "creates a new user and adds an account to the external panel" do
      post :create, params: { user: { username: 'testuser', password: 'password' } }
      expect(response).to redirect_to(user_path(assigns(:user)))
      expect(assigns(:user).id).to eq('dummy_panel_user_id')
    end
  end
end