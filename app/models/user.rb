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

  validates :name, :last_name, :id_number, :department, :position, presence: true
  validates :id_number, uniqueness: true

  has_many :logs

  has_secure_password

  enum role: %i[employee admin]

  def set_default_role
    role = self.role ||= :employee

    self.role = role
  end

  def report(start_day:, end_day:)
    logs = get_logs(start_day: start_day, end_day: end_day)

    build_report(logs: logs)
  end

  def get_logs(start_day:, end_day:)
    Log.all.where("user_id = ? and check_in >= ? and check_out <= ?", self.id, start_day, end_day)
  end

  def build_report(logs:)
    {
      employee_id: self.id,
      total_logs:  logs.count,
      logs:        log_summary(logs: logs)
    }
  end

  def log_summary(logs:)
    logs.map do |log|
      {
        check_in:  log.check_in,
        check_out: log.check_out
      }
    end
  end
end
