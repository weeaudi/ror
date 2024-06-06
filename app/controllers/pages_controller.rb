class PagesController < ApplicationController

  def index
    @test = Rails.application.credentials[:test]
  end

end
