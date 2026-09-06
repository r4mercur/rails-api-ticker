class TickerEvent < ApplicationRecord
  belongs_to :ticker
  belongs_to :user
  belongs_to :team, optional: true
  belongs_to :player, optional: true
  belongs_to :fk_player1, optional: true, class_name: 'Player'
  belongs_to :fk_player2, optional: true, class_name: 'Player'

  # NOTE: `event_id` used to carry a (ticker_id, event_id) uniqueness pair,
  # but nothing ever sets event_id (not the controller's strong params, not
  # the frontend) — with it always nil, the constraint capped every ticker
  # at exactly one event, which breaks the core multi-event ticker feature.
  # Removed; see spec/requests/api/v1/ticker_events_spec.rb's older workaround.

  validates :minute, presence: true
  validates :minute, format: {
    with: /\A\d{2}:\d{2}\z/,
    message: "format must be 'MM:SS'"
  }

  after_commit :recalculate_score, on: %i[create update destroy]

  private

  # Cheap enough (one grouped count query) to just always run rather than
  # trying to detect whether this particular change could affect the score.
  def recalculate_score
    ScoreCalculator.recalculate!(ticker)
  end
end
