class User < ApplicationRecord
  has_secure_password unless method_defined?(:authenticate)

  ROLES = %w[user admin service_centre].freeze unless const_defined?(:ROLES)

  before_validation :normalize_email
  before_validation :set_default_role

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }
  has_secure_password

  has_many :vehicles, dependent: :destroy
  has_many :serviced_records,
           class_name: "ServiceRecord",
           foreign_key: "serviced_by",
           dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true
  private

  def normalize_email
    self.email = email.to_s.downcase.strip if email.present?
  end

  def set_default_role
    self.role ||= "user"
  end
end
