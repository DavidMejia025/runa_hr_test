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

require 'rails_helper'

RSpec.describe Log, type: :model do
  it { is_expected.to validate_presence_of(:arrival_time) }
end
