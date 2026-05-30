class ServiceType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :recommended_days, presence: true,
                               numericality: { only_integer: true, greater_than: 0 }
  has_many :service_records, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :recommended_days, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
