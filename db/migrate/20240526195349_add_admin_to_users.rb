# frozen_string_literal: true

# adds whether a user is an admin or not
class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
