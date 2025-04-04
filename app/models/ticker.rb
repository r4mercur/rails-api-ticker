class Ticker < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :game_id, presence: true
  validates :user_id, presence: true

  enum ticket_state: {
    not_started: 0,
    first_half: 1,
    second_half: 2,
    third_half: 3,
    fourth_half: 4,
    ended: 5,
    half_time: 999
  }
end
