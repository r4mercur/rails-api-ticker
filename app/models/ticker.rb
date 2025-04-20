class Ticker < ApplicationRecord
  belongs_to :game
  belongs_to :user

  has_many :ticker_events

  validates :game_id, presence: true
  validates :user_id, presence: true
  validates :ticker_state, presence: true

  attribute :ticker_state, :integer

  enum ticker_state: {
    not_started: 0,
    first_half: 1,
    second_half: 2,
    third_half: 3,
    fourth_half: 4,
    ended: 5,
    half_time: 999
  }

  after_initialize :set_default_ticker_state, if: :new_record?

  def set_default_ticker_state
    self.ticker_state ||= :not_started
  end
end