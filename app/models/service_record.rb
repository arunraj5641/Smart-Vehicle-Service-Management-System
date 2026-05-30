class ServiceRecord < ApplicationRecord
  VALID_STATUS_TRANSITIONS = {
    nil => ["scheduled"],
    "scheduled" => ["in_progress"],
    "in_progress" => ["completed"],
    "completed" => []
  }.freeze

  before_validation :set_default_status

  belongs_to :vehicle
  belongs_to :service_type

  belongs_to :serviced_by_user,
             class_name: "User",
             foreign_key: "serviced_by",
             optional: true

  validates :service_date, presence: true
  validates :cost, presence: true,
                   numericality: { greater_than_or_equal_to: 0 }

  validates :vehicle_id, presence: true
  validates :service_type_id, presence: true

  validates :status, presence: true,
                     inclusion: { in: %w[scheduled in_progress completed] }
  validate :service_type_belongs_to_servicing_centre
  validate :status_transition_is_valid, if: :will_save_change_to_status?

  private

  def set_default_status
    self.status ||= "scheduled"
  end

  def service_type_belongs_to_servicing_centre
    return if service_type.blank? || serviced_by_user.blank?
    return if serviced_by_user.role == "admin"
    return if service_type.service_centre_id == serviced_by

    errors.add(:service_type_id, "does not belong to this service centre")
  end

  def status_transition_is_valid
    from_status = status_in_database
    return if VALID_STATUS_TRANSITIONS.fetch(from_status, []).include?(status)

    errors.add(:status, "cannot transition from #{from_status || 'none'} to #{status}")
  end
end
