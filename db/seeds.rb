# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.destroy_all
Log.destroy_all

def create_log (user_id, check_in, check_out)
  Log.create!(
    user_id:   user_id,
    check_in:  check_in,
    check_out: check_out
  )
end

def date_time_in(days);  Faker::Time.backward(days: days, period: :morning) end
def date_time_out(days); Faker::Time.backward(days: days, period: :evening) end

def create_users
  User.create!(
    name:        "david",
    last_name:   "mejia",
    id_number:   10001,
    department:  :Tech,
    position:    "Software Engineer",
    password:    "12345678",
    role:        :admin
  )

  User.create!(
    name:        "Ana",
    last_name:   "Naranjo",
    id_number:   10002,
    department:  :Sales,
    position:    "Account representative",
    password:    "12345678"
  )

  User.create!(
    name:        "Juan",
    last_name:   "Valencia",
    id_number:   10003,
    department:  :Product,
    position:    "UX",
    password:    "12345678"
  )
end

def admin
  User.all.first
end

def juan
  User.all.second
end

def ana
  User.all.last
end

def add_logs_to_user(user, logs_number, rand_number)
  logs_number.times do |days_before_today|
    if rand(rand_number).floor == 0
      create_log(
        user.id,
        date_time_in(days_before_today),
        date_time_in(days_before_today)
      )
    end
  end
end

create_users

add_logs_to_user(admin, 7, 0)
add_logs_to_user(ana,  96, 0)
add_logs_to_user(juan, 96, 2)

p Log.all.count
