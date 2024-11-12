# frozen_string_literal: true

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

# Get data from JSON files
def get_data_from_json(file_name)
  file = File.read(Rails.root.join('db', 'datasets', file_name))
  JSON.parse(file)
end

# Competitions
competitions_data = get_data_from_json('competitions.json')
competitions_data['competitions'].each do |competition|
  Competition.find_or_create_by!(name: competition['name'])
end

# Teams
teams_data = get_data_from_json('teams.json')
teams_data['teams'].each do |team|
  Team.find_or_create_by!(name: team['name'], shortname: team['shortName'])
end

# Players
players_data = get_data_from_json('players.json')
players_data['players'].each do |player|
  Player.find_or_create_by!(
    name: player['name'],
    age: player['age'],
    number: player['number'],
    position: player['position']
  )
end

# Users
10.times do
  User.create(
    email: Faker::Internet.email,
    password: Faker::Internet.password,
    is_admin: false
  )
end
