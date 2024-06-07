# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServersController, type: :controller do
  describe 'GET #index' do
    before do
      user = FactoryBot.create(:user)
      sign_in user

      allow(PanelApiInterface).to receive(:find_all_servers).and_return(
        {
          'object' => 'server',
          'attributes' => {
            'id' => 5,
            'external_id' => 'RemoteId1',
            'uuid' => '1a7ce997-259b-452e-8b4e-cecc464142ca',
            'identifier' => '1a7ce997',
            'name' => 'Gaming',
            'description' => 'Matt from Wii Sports',
            'suspended' => false,
            'limits' => {
              'memory' => 512,
              'swap' => 0,
              'disk' => 200,
              'io' => 500,
              'cpu' => 0,
              'threads' => nil
            },
            'feature_limits' => {
              'databases' => 5,
              'allocations' => 5,
              'backups' => 2
            },
            'user' => 1,
            'node' => 1,
            'allocation' => 1,
            'nest' => 1,
            'egg' => 5,
            'pack' => nil,
            'container' => {
              'startup_command' => 'java -Xms128M -Xmx{{SERVER_MEMORY}}M -jar {{SERVER_JARFILE}}',
              'image' => 'quay.io/pterodactyl/core:java',
              'installed' => true,
              'environment' => {
                'SERVER_JARFILE' => 'server.jar',
                'VANILLA_VERSION' => 'latest',
                'STARTUP' => 'java -Xms128M -Xmx{{SERVER_MEMORY}}M -jar {{SERVER_JARFILE}}',
                'P_SERVER_LOCATION' => 'GB',
                'P_SERVER_UUID' => '1a7ce997-259b-452e-8b4e-cecc464142ca',
                'P_SERVER_ALLOCATION_LIMIT' => 5
              }
            },
            'updated_at' => '2020-07-19T15:22:39+00:00',
            'created_at' => '2019-12-23T06:46:27+00:00'
          }
        }
      )
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end
end
