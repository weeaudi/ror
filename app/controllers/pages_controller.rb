# frozen_string_literal: true

class PagesController < ApplicationController
  def index
    @test = Rails.application.credentials[:test]
  end
end
