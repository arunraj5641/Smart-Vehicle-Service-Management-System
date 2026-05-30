class ServiceRecord < ApplicationRecord
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

  private

  def set_default_status
    self.status ||= "scheduled"
  end
end
