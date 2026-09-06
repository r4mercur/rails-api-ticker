class Api::V1::GamesController < ApplicationController
  before_action :set_game, only: %i[ show update destroy ]

  # Ticker is included so schedule views can show live/planned/finished status
  # and the (cached) score without an extra request per game.
  GAME_INCLUDES = {
    team_home: {},
    team_away: {},
    ticker: { only: %i[id ticker_state goals_home goals_away] }
  }.freeze

  # GET /games
  def index
    @games = paginate(Game.includes(:team_home, :team_away, :ticker).all)
    render json: @games, include: GAME_INCLUDES
  end

  # GET /games/1
  def show
    render json: @game, include: GAME_INCLUDES
  end

  # POST /games
  def create
    @game = Game.new(game_params)

    if @game.save
      render json: @game, status: :created, location: [:api, :v1, @game]
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/1
  def update
    if @game.update(game_params)
      render json: @game
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy!
  end

  private
    def set_game
      @game = Game.includes(:team_home, :team_away, :ticker).find(params[:id])
    end

    def game_params
      params.require(:game).permit(:competition_id, :team_home_id, :team_away_id, :match_day, :location, :date)
    end
end