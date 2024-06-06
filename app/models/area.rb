# app/models/area.rb
class Area < ApplicationRecord
  has_many :api_token_areas
  has_many :api_tokens, through: :api_token_areas
end
