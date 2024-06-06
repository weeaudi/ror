class ApiTokenArea < ApplicationRecord
  self.primary_key = 'api_token_id'
  belongs_to :api_token
  belongs_to :area
  enum permission: { ap_rw: 0, ap_r: 1, ap_none: 2 } # Define the enum for permission
end