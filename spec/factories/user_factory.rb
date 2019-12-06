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

require 'faker'

FactoryBot.define do
  factory :user do
    name       { Faker::Name.first_name  }
    last_name  { Faker::Name.last_name  }
    id_number  { rand(100)}
    password   { "123456789" }
    department { 0 }
    position   { "Software Engineer" }
    role       { 1 }
  end
end
