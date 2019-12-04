require 'rails_helper'

RSpec.describe Log, type: :model do
  it { is_expected.to validate_presence_of(:arrival_time) }
end
