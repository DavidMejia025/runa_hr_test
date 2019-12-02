class User < ApplicationRecord
  after_initialize :set_default_role, :if => :new_record?

  has_secure_password

  enum role: %i[employee admin]

  def set_default_role
    self.role ||= :employee
  end
end
