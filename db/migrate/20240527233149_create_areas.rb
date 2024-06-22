# frozen_string_literal: true

# create areas that api tokens can access
class CreateAreas < ActiveRecord::Migration[7.1]
  def change
    create_table :areas do |t|
      t.string :name
      t.timestamps
    end
  end
end
