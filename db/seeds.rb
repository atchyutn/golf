# require 'faker'
Admin.create(email: "admin@gmail.com", password: "ADMIN@123")

# require 'faker'

# Chat room for existing matches
Match.find_each do |match|
  ChatRoom.find_or_create_by!(match: match, name: "chat_room_#{match.id}")
end

ImportDataJob.new(club_csv: 'club_level_data.csv').perform_now
ImportDataJob.new(home_course_csv: 'home_course_new.csv').perform_now
ImportDataJob.new(tee_csv: 'new_tees.csv').perform_now

#Skip team player validation and magic link during seeding
ENV['SKIP_TEAM_PLAYER_VALIDATION'] = 'true'
ENV['SKIP_MAGIC_LINK'] = 'true'

# ========== NEW TEAMS AND PLAYERS SEEDING ==========
puts "Creating 30 teams with 2 players each..."

30.times do |i|
  # Create team first
  team = Team.create!(
    name: "Team_#{i+1}",
    payment_status: :completed
  )

  # Create captain (first player)
  captain = User.new(
    first_name: "captain_team#{i+1}",
    last_name: "captain_team#{i+1}",
    email: "captain_team#{i+1}@yopmail.com",
    # email: "captain_team#{i+1}_#{Faker::Internet.unique.user_name}@yopmail.com",
    password: 'password123',
    handicap: rand(0..36).to_s,
    player_type: 'captain',
    active: true
  )
  captain.team = team
  captain.save!

  # Create player (second player)
  player = User.new(
    first_name: "player_team#{i+1}",
    last_name: "player_team#{i+1}",
    email: "player_team#{i+1}@yopmail.com",
    # email: "player_team#{i+1}_#{Faker::Internet.unique.user_name}@yopmail.com",
    password: 'password123',
    handicap: rand(0..36).to_s,
    player_type: 'player',
    active: true
  )
  player.team = team
  player.save!

  puts "Team #{team.name} created with:"
  puts "  - Captain: #{captain.first_name} #{captain.last_name} (handicap: #{captain.handicap}, email: #{captain.email})"
  puts "  - Player: #{player.first_name} #{player.last_name} (handicap: #{player.handicap}, email: #{player.email})"
  puts "----------------------------------"
end

puts "Successfully created 30 teams with 2 players each!"

# Rest of your existing seed file...
# (Keep all the remaining code that creates regions, clubs, home courses, etc.)


# payment_status_completed = 2
# uk_numbers = ["+447464736755","+447464751722","+447501556309","+447769578549","+447769594661","+447822031221","+447822031222","+447822031223","+447822031224","+447822031225","+447822031226","+447822031227","+447822031228","+447822031229"]
# # home_course_ids = HomeCourse.where(holes_count: 18).ids

# # Skip team player validation and magic link during seeding
# ENV['SKIP_TEAM_PLAYER_VALIDATION'] = 'true'
# ENV['SKIP_MAGIC_LINK'] = 'true'

# # Seed Regions
# regions = []
# 5.times do |i|
#   regions << Region.create!(
#     name: "Region #{i + 1}"
#   )
# end
# puts "Seeded #{regions.count} regions."

# # Seed Clubs
# clubs = []
# 10.times do |i|
#   clubs << Club.create!(
#     name: "Club #{i + 1}"
#   )
# end
# puts "Seeded #{clubs.count} clubs."

# # Seed Home Courses
# home_courses = []
# 10.times do |i|
#   home_courses << HomeCourse.create!(
#     name: "Home Course #{i + 1}",
#     club_id: clubs[i].id
#   )
# end
# puts "Seeded #{home_courses.count} home courses."

# # Seed Tees
# tees = []
# 30.times do |i|
#   tees << Tee.create!(
#     name: "Tee #{i + 1}",
#     home_course_id: home_courses[i % 10].id,
#     club_id: clubs[i % 10].id
#   )
# end
# puts "Seeded #{tees.count} tees."

# # Seed Tournaments
# tournaments = []
# 3.times do |i|
#   tournaments << Tournament.create!(
#     name: "Tournament #{i + 1}",
#     tournament_type: [:single_elimination, :double_elimination].sample,
#     url: Faker::Internet.url,
#     description: Faker::Lorem.sentence,
#     start_at: Faker::Time.forward(days: 30),
#     region_id: regions[i].id
#   )
# end
# puts "Seeded #{tournaments.count} tournaments."

# # Seed Cohors
# cohors_list = []
# 3.times do |i|
#   cohors_list << Cohors.create!(
#     name: "Cohors #{i + 1}",
#     tournament_type: [:single_elimination, :double_elimination].sample,
#     game_name: Faker::Game.title,
#     starts_at: Faker::Time.forward(days: 30),
#     url: Faker::Internet.url,
#     description: Faker::Lorem.sentence,
#     region_id: regions[i].id,
#     state: %w[pending underway complete awaiting_review].sample
#   )
# end
# puts "Seeded #{cohors_list.count} cohors."

# # Seed Teams and Users together
# teams = []
# cohors_list.each_with_index do |cohors, cohors_index|
#   4.times do |i|
#     # Create team with a unique name
#     team = Team.create!(
#       name: "Team #{cohors_index * 4 + i + 1}",
#       tournament_id: tournaments[cohors_index].id,
#       home_course_id: home_courses[i].id,
#       payment_status: :completed,
#       eliminated: false,
#       disqualified: false,
#       cohors_id: cohors_list[cohors_index].id
#     )
#     teams << team

#     # Create 2 users per team
#     2.times do |j|
#       User.create!(
#         first_name: Faker::Name.first_name,
#         last_name: Faker::Name.last_name,
#         email: Faker::Internet.unique.email(domain: 'yopmail.com'),
#         team_id: team.id,
#         player_type: j.zero? ? :captain : :player,
#         phone_number: "+44#{Faker::Number.number(digits: 10)}",
#         password: 'password123',
#         active: true
#       )
#     end
#   end
# end

# # Create additional unassigned teams for manual testing
# 5.times do |i|
#   team = Team.create!(
#     name: "Unassigned Team #{i + 1}",
#     home_course_id: home_courses[rand(home_courses.count)].id,
#     payment_status: :completed,
#     eliminated: false,
#     disqualified: false,
#     cohors_id: nil,
#     tournament_id: nil
#   )
#   teams << team

#   # Create 2 users per team
#   2.times do |j|
#     User.create!(
#       first_name: Faker::Name.first_name,
#       last_name: Faker::Name.last_name,
#       email: Faker::Internet.unique.email(domain: 'yopmail.com'),
#       team_id: team.id,
#       player_type: j.zero? ? :captain : :player,
#       phone_number: "+44#{Faker::Number.number(digits: 10)}",
#       password: 'password123',
#       active: true
#     )
#   end
# end

# puts "Seeded #{teams.count} teams."

# # Seed Matches
# matches = []
# match_attempts = 0
# max_match_attempts = 50

# # Gather all users with a team
# team_users = User.joins(:team).where.not('teams.id': nil)

# while matches.length < 15 && match_attempts < max_match_attempts
#   # Ensure players are from different teams
#   player1, player2 = team_users.sample(2)
  
#   # Skip if players are from the same team or if either player is nil
#   if player1.nil? || player2.nil? || player1.team_id == player2.team_id
#     match_attempts += 1
#     next
#   end
  
#   begin
#     match = Match.create!(
#       match_time: Faker::Time.forward(days: 20),
#       status: [0, 1, 2].sample,
#       tournament_id: tournaments.sample.id,
#       cohors_id: cohors_list.sample.id,
#       match_id: SecureRandom.uuid,
#       round: Faker::Number.between(from: 1, to: 5),
#       home_course_id: home_courses.sample.id,
#       early_win: [true, false].sample
#     )
    
#     # Create match teams
#     MatchTeam.create!(match: match, team: player1.team)
#     MatchTeam.create!(match: match, team: player2.team)
    
#     matches << match
#   rescue ActiveRecord::RecordInvalid
#     match_attempts += 1
#   end
# end
# puts "Seeded #{matches.count} matches."

# # Seed Admins
# Admin.create!(
#   email: 'admin@yopmail.com',
#   password: 'password',
#   password_confirmation: 'password'
# )
# puts "Seeded admin with email admin@yopmail.com"

# 5.times do
#   Admin.create!(
#     email: Faker::Internet.email(domain: 'yopmail.com'),
#     password: 'password123',
#     password_confirmation: 'password123'
#   )
# end
# puts "Seeded additional admins."

# puts "Seeding completed!"
#   puts "Team #{team.name} created with captain #{captain.full_name} and player #{player.full_name}"
# # end

# # Chat room for existing mateches
# Match.find_each do |match|
#   ChatRoom.find_or_create_by!(match: match, name: "chat_room_#{match.id}")
# end
