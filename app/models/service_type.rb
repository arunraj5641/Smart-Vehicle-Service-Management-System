class ServiceType < ApplicationRecord
  belongs_to :service_centre, class_name: "User"
  has_many :service_records, dependent: :destroy

  validates :service_centre, presence: true
  validates :name, presence: true, uniqueness: { scope: :service_centre_id, case_sensitive: false }
  validates :recommended_days, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
