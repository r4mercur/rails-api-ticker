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
  before_create :generate_public_slug

  def set_default_ticker_state
    self.ticker_state ||= :not_started
  end

  private

  # Human-readable public link slug, e.g. "fcb-bvb-12-09" — mirrors the
  # mockup's `/live/rwh-gwv-13-09` style. Collisions (rare: same two teams
  # on the same day, or a rematch) get a numeric suffix.
  def generate_public_slug
    base = "#{game.team_home.shortname}-#{game.team_away.shortname}-#{game.date.strftime('%d-%m')}".parameterize
    slug = base
    suffix = 1
    while Ticker.exists?(public_slug: slug)
      suffix += 1
      slug = "#{base}-#{suffix}"
    end
    self.public_slug = slug
  end
end