# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string
#  last_name       :string
#  id_number       :integer
#  role            :integer
#  department      :integer
#  position        :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  after_initialize :set_default_role, :if => :new_record?

  has_secure_password

  enum role: %i[employee admin]

  def set_default_role
    self.role ||= :employee
  end
end
