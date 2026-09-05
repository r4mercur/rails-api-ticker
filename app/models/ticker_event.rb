class TickerEvent < ApplicationRecord
  belongs_to :ticker
  belongs_to :user
  belongs_to :team, optional: true
  belongs_to :player, optional: true
  belongs_to :fk_player1, optional: true, class_name: 'Player'
  belongs_to :fk_player2, optional: true, class_name: 'Player'

  validates :ticker_id, uniqueness: { scope: :event_id }
  validates :event_id, uniqueness: { scope: :ticker_id }

  validates :minute, presence: true
  validates :minute, format: {
    with: /\A\d{2}:\d{2}\z/,
    message: "format must be 'MM:SS'"
  }
end
