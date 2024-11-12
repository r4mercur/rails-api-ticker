# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'
require 'json'

# Competitions
competitions_file = File.read(Rails.root.join('db', 'datasets', 'competitions.json'))
competitions_data = JSON.parse(competitions_file)

competitions_data['competitions'].each do |competition|
  Competition.find_or_create_by!(name: competition['name'])
end

# Teams
teams_file = File.read(Rails.root.join('db', 'datasets', 'teams.json'))
teams_data = JSON.parse(teams_file)

teams_data['teams'].each do |team|
  Team.find_or_create_by!(name: team['name'], shortname: team['shortname'])
end

# Users
10.times do
  User.create(
    email: Faker::Internet.email,
    password: Faker::Internet.password,
    is_admin: false
  )
end