class ApplicationController < ActionController::API
  include ResponseHandler
  include Pagination

  attr_reader :current_user

  rescue_from StandardError, with: :handle_internal_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActiveRecord::NotNullViolation, with: :handle_db_error
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

  # Accessors
  def current_user
    @current_user ||= begin
      auth_header = request.headers["Authorization"]
      token = auth_header.to_s.split(" ").last
      return nil if token.blank?

      decoded = Auth::JsonWebToken.decode(token)
      return nil if decoded.blank?

      User.find(decoded[:user_id])
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # Authentication Filter
  def authenticate_user!
    return if current_user.present?

    render_error(
      message: "Authentication token is invalid, expired, or missing",
      status: :unauthorized,
      errors: { token: ["is invalid or missing"] }
    )
  end

  # Role-Based Access Control
  def authorize_role!(allowed_roles)
    allowed_roles = Array(allowed_roles).map(&:to_s)
    return if current_user.present? && allowed_roles.include?(current_user.role)

    render_error(
      message: "You are not authorized to perform this action",
      status: :forbidden,
      errors: { role: ["is not permitted"] }
    )
  end

  def require_admin!
    authorize_role!("admin")
  end

  def require_service_centre!
    authorize_role!(["admin", "service_centre"])
  end

  # Helper to resolve client permissions for UI elements
  def permissions_for(resource_type, record = nil)
    role = current_user&.role

    # Default to completely restricted
    permissions = {
      can_view: false,
      can_create: false,
      can_update: false,
      can_delete: false,
      can_update_status: false
    }

    return permissions if role.blank?

    # Admins always have complete privileges
    return {
      can_view: true,
      can_create: true,
      can_update: true,
      can_delete: true,
      can_update_status: true
    } if role == "admin"

    case resource_type.to_sym
    when :vehicle
      return permissions.merge!(can_view: true, can_create: true, can_update: true) if role == "service_centre"

      is_owner = record.nil? || record.user_id == current_user.id
      permissions.merge!(
        can_view: is_owner,
        can_create: true,
        can_update: is_owner
      )
    when :service_type
      return permissions.merge!(can_view: true, can_create: true, can_update: true) if role == "service_centre"
      permissions.merge!(can_view: true)
    when :service_record
      return permissions.merge!(can_view: true, can_create: true, can_update: true, can_update_status: true) if role == "service_centre"

      is_owner = record.nil? || record.vehicle.user_id == current_user.id
      permissions.merge!(
        can_view: is_owner,
        can_create: true,
        can_update: is_owner,
        can_update_status: is_owner
      )
    when :user
      is_self = record.nil? || record.id == current_user.id
      permissions.merge!(
        can_view: is_self,
        can_update: is_self
      )
    end

    permissions
  end

  private

def authenticate_request
  payload = JsonWebToken.decode(bearer_token)
  return render_error(message: "Unauthorized", status: :unauthorized) unless payload

  @current_user = User.find(payload[:user_id])
end

def authorize_roles(*roles)
  return render_error(message: "Unauthorized", status: :unauthorized) unless current_user
  return if roles.map(&:to_s).include?(current_user.role)

  render_error(message: "Forbidden", status: :forbidden)
end

def bearer_token
  request.headers["Authorization"].to_s.split.last
end

def handle_parameter_missing(error)
  render_error(
    message: "Missing required parameter",
    status: :bad_request,
    errors: { error.param => ["is required"] }
  )
end
 
 def handle_not_found(error)
    render_error(
      message: error.message,
      status: :not_found,
      errors: { id: ["not found"] }
    )
  end

  def handle_validation_error(error)
    render_error(
      message: "Validation failed: #{error.record.errors.full_messages.join(', ')}",
      status: :unprocessable_entity,
      errors: error.record.errors.messages
    )
  end

  def handle_db_error(error)
    render_error(
      message: "Database integrity violation",
      status: :unprocessable_entity,
      errors: { database: ["violates database constraints"] }
    )
  end

  def handle_internal_error(error)
    Rails.logger.error(error.message)
    Rails.logger.error(error.backtrace.join("\n"))

    render_error(
      message: "An internal server error occurred",
      status: :internal_server_error,
      errors: { server: ["unexpected error"] }
    )
  end
end
