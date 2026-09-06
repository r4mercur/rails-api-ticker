class GameLineup < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :player_id, uniqueness: { scope: :game_id }
end
