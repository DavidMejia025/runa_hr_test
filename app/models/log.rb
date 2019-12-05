# == Schema Information
#
# Table name: logs
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  check_in   :datetime
#  check_out  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Log < ApplicationRecord
  validates :check_in, presence: true

  belongs_to :user
end
