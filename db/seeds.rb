# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
demo_user = User.create!(fullname: "Demo Boy", email: "paperclub-demo@gmail.com",
                          avatar_url: "", 
                          password: "123456", password_confirmation: "123456")
debug_club = Club.create!(name: "Demo Club", 
                          description: "This club is for demo purpose only")
membership = Membership.create!(role: "admin", 
                               club_id: debug_club.id, user_id: demo_user)
