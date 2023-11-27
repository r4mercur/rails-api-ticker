class Game < ApplicationRecord
  belongs_to :competition
  belongs_to :team_home, class_name: 'Team'
  belongs_to :team_away, class_name: 'Team'

  validates :team_home_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :team_away_score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :match_day, numericality: { greater_than_or_equal_to: 1 }
  validates :date, presence: true
  validates :location, presence: true

  validate :teams_must_be_different
  validate :check_if_teams_in_competition

  def teams_must_be_different
    if team_home == team_away
      errors.add(:team_home, 'must be different from team away')
    end
  end

  def check_if_teams_in_competition
    unless competition.teams.include?(team_home)
      errors.add(:team_home, 'must be participating in competition')
    end
    unless competition.teams.include?(team_away)
      errors.add(:team_away, 'must be participating in competition')
    end
  end
end