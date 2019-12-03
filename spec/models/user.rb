require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:id_number) }
  it { is_expected.to validate_presence_of(:department) }
  it { is_expected.to validate_presence_of(:position) }
end
