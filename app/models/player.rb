class Player < ApplicationRecord
  belongs_to :team

  enum status: { active: 0, injured: 1, suspended: 2 }

  has_many :ticker_events
  has_many :player_1_events, class_name: 'TickerEvent', foreign_key: 'fk_player1_id'
  has_many :player_2_events, class_name: 'TickerEvent', foreign_key: 'fk_player2_id'

  def self.search(search)
    if search
      where(["name LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
