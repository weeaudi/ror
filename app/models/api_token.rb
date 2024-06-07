class ApiToken < ApplicationRecord
  validates :token, presence: true, uniqueness: true

  serialize :allowed_ips, coder: JSON

  has_many :api_token_areas
  has_many :areas, through: :api_token_areas
  accepts_nested_attributes_for :api_token_areas
end
