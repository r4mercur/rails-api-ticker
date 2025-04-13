class Team < ApplicationRecord
  has_many :participations
  has_many :competitions, through: :participations
  has_many :players

  has_many :home_games, class_name: 'Game', foreign_key: 'team_home_id'
  has_many :away_games, class_name: 'Game', foreign_key: 'team_away_id'
end
