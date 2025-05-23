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
  file_path = Rails.root.join('db', 'datasets', file_name)
  file_content = File.read(file_path)
  puts "Reading file: #{file_path}"
  puts "File content: #{file_content}"
  JSON.parse(file_content)
rescue JSON::ParserError => e
  puts "JSON::ParserError: #{e.message}"
  raise
end

# Competitions
competitions_data = get_data_from_json('competitions.json')
competitions_data['competitions'].each do |competition|
  Competition.find_or_create_by!(name: competition['name'])
end

# Teams
teams_data = get_data_from_json('teams.json')
teams_data['teams'].each do |competition_data|
  competition = Competition.find_by(name: competition_data['competition'])
  competition_data['teams'].each do |team|
    team = Team.find_or_create_by!(
      name: team['name'],
      shortname: team['shortName'],
      logo_url: team['logoUrl']
    )

    # Add team to competition
    Participation.find_or_create_by!(
      team: team,
      competition: competition
    )
  end
end

# Players
players_data = get_data_from_json('players.json')
players_data['players'].each do |player_data|
  team = Team.find_by(name: player_data['team'])
  if team.nil?
    puts "Team not found: #{player_data['team']}"
    next
  end
  player_data['players'].each do |player|
    Player.find_or_create_by!(
      name: player['name'],
      age: player['age'],
      number: player['number'],
      position: player['position'],
      team: team
    )
    puts "Player created: #{player['name']}"
  end
end

# Games
teams_data['teams'].each do |competition_data|
  competition = Competition.find_by(name: competition_data['competition'])
  next if competition.nil?

  # here we are creating games for each team in the competition
  # we are creating a game for each team against each other team
  # so if we 18 teams we will have 18 * 17 games
  competition_data['teams'].each do |team_data|
    home_team = Team.find_by(name: team_data['name'])
    next if home_team.nil?

    competition_data['teams'].each_with_index do |away_team_data, index|
      away_team = Team.find_by(name: away_team_data['name'])
      next if away_team.nil?

      next if home_team == away_team

      random_date = Faker::Date.between(from: 1.year.ago, to: 1.year.from_now)
      match_time = Faker::Time.between(from: random_date.to_time + 15.hours,
                                       to: random_date.to_time + 20.hours + 30.minutes)


      Game.find_or_create_by!(
        team_home: home_team,
        team_away: away_team,
        competition: competition,
        match_day: index + 1,
        date: match_time,
        location: Faker::Address.full_address
      )
    end
  end
end

# Users
10.times do
  User.create(
    email: Faker::Internet.email,
    username: Faker::Internet.user_name,
    password: Faker::Internet.password
  )
end
