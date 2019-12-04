class Log < ApplicationRecord
  validates :arrival_time, presence: true

  belongs_to :user
end
