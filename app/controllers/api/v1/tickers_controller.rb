class Api::V1::TickersController < ApplicationController
  before_action :set_ticker, only: %i[ update destroy ]

  # GET /tickers
  def index
    @tickers = paginate(Ticker.all)

    render json: @tickers
  end

  # GET /tickers/1
  def show
    @ticker = Ticker.includes(
      game: [{ team_home: :players }, { team_away: :players }],
      ticker_events: {}
    ).find(params[:id])

    render json: @ticker.as_json(include: {
      game: {
        include: {
          team_home: { include: :players },
          team_away: { include: :players }
        }
      },
      ticker_events: {}
    })
  end

  # POST /tickers
  def create
    @ticker = Ticker.new(ticker_params)

    if @ticker.save
      render json: @ticker.as_json(include: [:game]), status: :created, location: [:api, :v1, @ticker]
    else
      render json: @ticker.errors, status: :unprocessable_entity
    end
  end

  def get_ticker_by_user_id
    @ticker = Ticker.includes(game: %i[team_home team_away]).where(user_id: params[:id])
    render json: @ticker.as_json(include: { game: { include: %i[team_home team_away] } })
  end

  # PATCH/PUT /tickers/1
  def update
    if @ticker.update(ticker_params)
      render json: @ticker
    else
      render json: @ticker.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickers/1
  def destroy
    @ticker.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticker
      @ticker = Ticker.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticker_params
      params.require(:ticker).permit(
        :game_id, :user_id, :ticker_state,
        :possession_home, :possession_away,
        :shots_home, :shots_away,
        :shots_on_target_home, :shots_on_target_away,
        :corners_home, :corners_away,
        :fouls_home, :fouls_away
      )
    end
end
