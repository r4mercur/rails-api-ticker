class TickerEventsController < ApplicationController
  before_action :set_ticker_event, only: %i[ show update destroy ]

  # GET /ticker_events
  def index
    @ticker_events = TickerEvent.all

    render json: @ticker_events
  end

  # GET /ticker_events/1
  def show
    render json: @ticker_event
  end

  # POST /ticker_events
  def create
    @ticker_event = TickerEvent.new(ticker_event_params)

    if @ticker_event.save
      render json: @ticker_event, status: :created
    else
      render json: @ticker_event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /ticker_events/1
  def update
    if @ticker_event.update(ticker_event_params)
      render json: @ticker_event
    else
      render json: @ticker_event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /ticker_events/1
  def destroy
    @ticker_event.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticker_event
      @ticker_event = TickerEvent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ticker_event_params
      params.require(:ticker_event).permit(:ticker_id, :minute, :user_id, :event_type)
    end
end
