class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :service_records, dependent: :destroy
end