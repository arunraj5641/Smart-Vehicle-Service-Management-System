class Vehicle < ApplicationRecord
  validates :name, :model, :number_plate, presence: true
  validates :number_plate, uniqueness: true
  belongs_to :user
  has_many :service_records, dependent: :destroy

  validates :name, presence: true
  validates :model, presence: true
  validates :number_plate, presence: true, uniqueness: { case_sensitive: false }
  validates :user_id, presence: true
end
