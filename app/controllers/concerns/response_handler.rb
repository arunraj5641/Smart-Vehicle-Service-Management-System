module ResponseHandler
  extend ActiveSupport::Concern

  def render_success(data: nil, message: "Success", meta: nil, status: :ok)
    response = {
      success: true,
      message: message,
      data: data
    }

    response[:meta] = meta if meta

    render json: response, status: status
  end

  def render_error(message: "Something went wrong", status: :unprocessable_entity)
    render json: {
      success: false,
      message: message
    }, status: status
  end
end