# == Schema Information
#
# Table name: logs
#
#  id             :bigint           not null, primary key
#  user_id        :integer
#  arrival_time   :date
#  departure_time :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Log < ApplicationRecord
  validates :arrival_time, presence: true

  belongs_to :user
end
