require 'spec/rails_helper'

RSpec.describe ServersController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  # Add more tests for other actions here
end