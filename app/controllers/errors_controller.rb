# frozen_string_literal: true

# controller for custom error pages
class ErrorsController < ApplicationController
  def not_found
    render status: :not_found
  end

  def internal_server
    render status: :internal_server_error
  end

  def unprocessable
    render status: :unprocessable_entity
  end

  def unacceptable
    render status: :not_acceptable
  end
end
