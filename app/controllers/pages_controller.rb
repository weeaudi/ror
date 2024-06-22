# frozen_string_literal: true

# Controller for the main page
class PagesController < ApplicationController
  def index
    @test = Rails.application.credentials[:test]
  end
end
