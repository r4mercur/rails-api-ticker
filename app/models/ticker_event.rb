class TickerEvent < ApplicationRecord
  belongs_to :ticker
  belongs_to :user
  belongs_to :team, optional: true

  validates :ticker_id, uniqueness: { scope: :event_id }
  validates :event_id, uniqueness: { scope: :ticker_id }

  validates :minute, presence: true
  validates :minute, format: {
    with: /\A\d{2}:\d{2}\z/,
    message: "format must be 'MM:SS'"
  }
end
