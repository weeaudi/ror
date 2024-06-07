# frozen_string_literal: true

class CreateApiTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :api_tokens do |t|
      t.string :token
      t.text :allowed_ips, default: '[]'

      t.timestamps
    end
  end
end
