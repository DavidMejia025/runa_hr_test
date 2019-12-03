require 'faker'

FactoryBot.define do
  factory :user do

    name:       { Faker::Name.first_name  }
    last_name:  { Faker::Name.last_name  }
    id_number:  { Faker::Code.imei }
    password:   { Faker::Code.imei }
    department: { "Tech" }
    position:   { "Software Engineer" }
  end
end
