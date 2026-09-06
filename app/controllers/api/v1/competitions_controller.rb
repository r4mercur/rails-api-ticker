class Api::V1::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[show update destroy]

  # Standings only reveal team names/scores, same as any public league
  # table — reachable from the unauthenticated reader view's Tabelle tab.
  skip_before_action :require_login, only: %i[standings]

  # GET /competitions
  def index
    @competitions = paginate(Competition.all)

    render json: @competitions
  end

  # GET /competitions/1
  def show
    render json: @competition
  end

  def teams
    @competition = Competition.find(params[:id])
    @teams = @competition.teams
    render json: @teams
  end

  def games
    @competition = Competition.find(params[:id])
    @games = Game.includes(:team_home, :team_away, :ticker).where(competition_id: @competition.id)
    render json: @games, include: Api::V1::GamesController::GAME_INCLUDES
  end

  def games_by_day
    @competition = Competition.find(params[:id])
    @games = Game.includes(:team_home, :team_away, :ticker).where(competition_id: @competition.id, match_day: params[:game_day])
    render json: @games, include: Api::V1::GamesController::GAME_INCLUDES
  end

  # GET /competitions/:id/standings
  # Table is built only from finished (ticker_state: ended) games — a live
  # 0:0 shouldn't count as "played" yet.
  def standings
    @competition = Competition.find(params[:id])
    finished_games = Game.joins(:ticker)
                          .where(competition_id: @competition.id, tickers: { ticker_state: Ticker.ticker_states[:ended] })
                          .where.not(goals_home: nil).where.not(goals_away: nil)

    table = @competition.teams.map do |team|
      team_games = finished_games.select { |g| g.team_home_id == team.id || g.team_away_id == team.id }

      wins = draws = losses = goals_for = goals_against = 0
      team_games.each do |g|
        home = g.team_home_id == team.id
        gf = home ? g.goals_home : g.goals_away
        ga = home ? g.goals_away : g.goals_home
        goals_for += gf
        goals_against += ga
        if gf > ga
          wins += 1
        elsif gf == ga
          draws += 1
        else
          losses += 1
        end
      end

      {
        team_id: team.id,
        name: team.name,
        shortname: team.shortname,
        logo_url: team.logo_url,
        played: team_games.size,
        wins: wins,
        draws: draws,
        losses: losses,
        goals_for: goals_for,
        goals_against: goals_against,
        goal_difference: goals_for - goals_against,
        points: (wins * 3) + draws
      }
    end

    table.sort_by! { |row| [-row[:points], -row[:goal_difference], -row[:goals_for]] }

    render json: table
  end

  # POST /competitions
  def create
    @competition = Competition.new(competition_params)

    if @competition.save
      render json: @competition, status: :created, location: [:api, :v1, @competition]
    else
      render json: @competition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /competitions/1
  def update
    if @competition.update(competition_params)
      render json: @competition
    else
      render json: @competition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /competitions/1
  def destroy
    @competition.destroy!
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_competition
    @competition = Competition.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def competition_params
    params.require(:competition).permit(:name, :type)
  end
end
