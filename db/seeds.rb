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
demo_club = Club.create!(name: "Demo Club", 
                          description: "This club is for demo purpose only")
membership = Membership.create!(role: "admin", 
                               club_id: demo_club.id, user_id: demo_user.id)
demo_paper = Paper.create!( title: "The Case for Determinism in Database Systems", 
                            pub_date: 10.days.ago, 
                            uuid: "19oj9asdf21a9sdjklasd901as",
                            uploader_id: demo_user.id,
                            club_id: demo_club.id )
demo_tag1 = Tag.create!(name: "Database", club_id: demo_club.id)
demo_tag2 = Tag.create!(name: "VLDB", club_id: demo_club.id)
Collection.create!(paper_id: demo_paper.id, tag_id: demo_tag1.id)
Collection.create!(paper_id: demo_paper.id, tag_id: demo_tag2.id)
