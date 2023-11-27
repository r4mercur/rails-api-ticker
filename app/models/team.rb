class Team < ApplicationRecord
  has_many :participations
  has_many :competitions, through: :participations
end
