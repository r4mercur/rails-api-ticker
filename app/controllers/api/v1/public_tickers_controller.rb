# Unauthenticated, read-only endpoint for the public reader view
# (see vue-ticker's /live/:slug). Deliberately serializes only what a
# reader needs — no user ids, no internal editor metadata.
class Api::V1::PublicTickersController < ApplicationController
  skip_before_action :require_login
  skip_before_action :verify_origin!

  PUBLIC_INCLUDES = {
    game: {
      only: %i[id location date match_day goals_home goals_away competition_id],
      include: {
        team_home: {
          only: %i[id name shortname logo_url coach_name],
          include: { players: { only: %i[id name number position] } }
        },
        team_away: {
          only: %i[id name shortname logo_url coach_name],
          include: { players: { only: %i[id name number position] } }
        },
        lineups: { only: %i[id player_id starting position] }
      }
    },
    ticker_events: { only: %i[id minute event_type team_id player_id fk_player1_id fk_player2_id text] }
  }.freeze

  PUBLIC_ONLY = %i[
    id ticker_state
    possession_home possession_away
    shots_home shots_away
    shots_on_target_home shots_on_target_away
    corners_home corners_away
    fouls_home fouls_away
  ].freeze

  # GET /public/tickers/:slug
  def show
    @ticker = Ticker.includes(
      game: [{ team_home: :players }, { team_away: :players }, :lineups],
      ticker_events: {}
    ).find_by!(public_slug: params[:slug])

    render json: @ticker.as_json(only: PUBLIC_ONLY, include: PUBLIC_INCLUDES)
  end
end
