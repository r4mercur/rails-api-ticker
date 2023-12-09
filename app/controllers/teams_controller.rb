class TeamsController < ApplicationController
  before_action :set_team, only: %i[ show update destroy ]

  # GET /teams
  def index
    @teams = Team.all

    render json: @teams
  end

  # GET /teams/1
  def show
    render json: @team
  end

  # POST /teams
  def create
    @team = Team.new(team_params)

    if @team.save
      # create mapping participant to competition
      if params[:competition_id]
        @competition = Competition.find(params[:competition_id])
        @participation = Participation.create(team: @team, competition: @competition)
      end

      render json: @team, status: :created, location: @team
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end

  def upload_team_logo
    @team = Team.find(params[:id])
    if @team && params[:logo]
      base64_data = params[:logo].sub(/^data:image\/\w+;base64,/, '')
      file_data = Base64.decode64(base64_data)

      filename = "team_#{params[:id]}.png"
      filepath = Rails.root.join('public', 'images', filename)

      File.open(filepath, 'wb') do |file|
        file.write(file_data)
      end

      render json: { success: true, message: 'Logo uploaded successfully' }
    else
      render json: { success: false, message: 'Logo upload failed' }
    end
  end

  # PATCH/PUT /teams/1
  def update
    if @team.update(team_params)
      render json: @team
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end

  # DELETE /teams/1
  def destroy
    @team.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def team_params
      params.require(:team).permit(:name, :shortname, :competition_id)
    end
end
