# Recomputes a game's score from its ticker's goal-scoring events and caches
# it onto games.goals_home/goals_away, so reads stay a cheap column lookup
# instead of aggregating ticker_events on every request.
#
# event_type has no DB-level enum (see TickerEvent) — these numbers are the
# frontend/backend-shared convention (see vue-ticker src/helpers/index.js
# EventTypesEnum). GOAL(4) and PENALTY_GOAL(8) count for the scoring team;
# OWN_GOAL(9) also counts, but the ticker_event's team_id for an own goal
# must be set to the BENEFITING team (not the scorer's own team) when the
# event is created — the calculator just trusts team_id at face value.
# MISSED_PENALTY(10) intentionally does not count.
class ScoreCalculator
  GOAL_EVENT_TYPES = [4, 8, 9].freeze

  def self.recalculate!(ticker)
    new(ticker).recalculate!
  end

  def initialize(ticker)
    @ticker = ticker
  end

  def recalculate!
    game = @ticker.game
    return unless game

    goals = @ticker.ticker_events
                   .where(event_type: GOAL_EVENT_TYPES)
                   .where.not(team_id: nil)
                   .group(:team_id)
                   .count

    game.update_columns(
      goals_home: goals[game.team_home_id] || 0,
      goals_away: goals[game.team_away_id] || 0
    )
  end
end
