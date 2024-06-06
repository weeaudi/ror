@coderabbitai generate tests for this file

class PagesController < ApplicationController

  def index
    @test = Rails.application.credentials[:test]
  end

end
