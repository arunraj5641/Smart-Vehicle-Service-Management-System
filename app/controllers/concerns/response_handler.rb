module ResponseHandler
  extend ActiveSupport::Concern

  def render_success(data: {}, message: "Success", meta: {}, status: :ok)
    render json: {
      success: true,
      message: message,
      data: data || {},
      meta: { request_id: request.uuid }.merge(meta || {}),
      timestamp: Time.current.iso8601
    }, status: status
  end

  def render_error(message: "Something went wrong", status: :unprocessable_entity, errors: {})
    render json: {
      success: false,
      message: message,
      data: {},
      errors: errors || {},
      meta: { request_id: request.uuid },
      timestamp: Time.current.iso8601
    }, status: status
  end

  # Optional helpers
  def render_not_found(message: "Resource not found")
    render_error(
      message: message,
      status: :not_found,
      errors: { id: ["not found"] }
    )
  end

  def render_validation_errors(model)
    render_error(
      message: "Validation failed",
      status: :unprocessable_entity,
      errors: model.errors.messages
    )
  end
end
