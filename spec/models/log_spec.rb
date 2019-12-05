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

require 'rails_helper'

RSpec.describe Log, type: :model do
  it { is_expected.to validate_presence_of(:check_in) }
end
