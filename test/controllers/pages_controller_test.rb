require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe "GET #index" do
    before do
      user = FactoryBot.create(:user)
      sign_in user
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  # Add more tests for other actions here
end