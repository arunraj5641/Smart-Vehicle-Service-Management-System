class ApplicationController < ActionController::API
  include ResponseHandler
  include Pagination

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::NotNullViolation, with: :handle_db_error
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  rescue_from StandardError, with: :handle_internal_error

  private

  def handle_not_found(error)
    render_error(error.message, :not_found)
  end

  def handle_validation_error(error)
    render_error(error.record.errors.full_messages.join(", "), :unprocessable_entity)
  end

  def handle_db_error(error)
    render_error("Invalid data provided", :unprocessable_entity)
  end

  def handle_internal_error(error)
    Rails.logger.error(error.message)
    Rails.logger.error(error.backtrace.join("\n"))

    render_error("Internal server error", :internal_server_error)
  end
 end
end