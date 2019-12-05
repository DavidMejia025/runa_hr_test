require 'faker'

FactoryBot.define do
  factory :log do
    user

    check_in  { Faker::Time.backward(days: 7, period: :morning)  }
  end

  trait :complete do
    check_out { Faker::Time.backward(days: 7, period: :evening)  }
  end
end
