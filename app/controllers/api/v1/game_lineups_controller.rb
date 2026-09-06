class Api::V1::GameLineupsController < ApplicationController
  before_action :set_game
  before_action :set_lineup, only: %i[ update destroy ]

  # GET /games/:game_id/lineups
  def index
    render json: @game.lineups.includes(:player)
  end

  # POST /games/:game_id/lineups
  def create
    @lineup = @game.lineups.new(lineup_params)

    if @lineup.save
      render json: @lineup, status: :created
    else
      render json: @lineup.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /games/:game_id/lineups/:id
  def update
    if @lineup.update(lineup_params)
      render json: @lineup
    else
      render json: @lineup.errors, status: :unprocessable_entity
    end
  end

  # DELETE /games/:game_id/lineups/:id
  def destroy
    @lineup.destroy!
  end

  private
    def set_game
      @game = Game.find(params[:game_id])
    end

    def set_lineup
      @lineup = @game.lineups.find(params[:id])
    end

    def lineup_params
      params.require(:game_lineup).permit(:player_id, :starting, :position)
    end
end
