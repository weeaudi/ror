# frozen_string_literal: true

class CreateApiTokenAreasJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :api_token_areas, id: false do |t|
      t.belongs_to :api_token
      t.belongs_to :area
      t.integer :permission, default: 2 # Default permission is 'none'
    end
  end
end
