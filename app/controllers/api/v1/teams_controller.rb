class Api::V1::TeamsController < ApplicationController
  before_action :set_team, only: %i[ show update destroy ]

  # GET /teams
  def index
    @teams = paginate(Team.all)

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

  # The client always requests the logo back as "team_<id>.png" (see TeamView.vue),
  # so every accepted format is normalized to a .png filename on disk.
  ALLOWED_LOGO_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  MAX_LOGO_SIZE = 5.megabytes

  def upload_team_logo
    @team = Team.find(params[:id])
    match = params[:logo].to_s.match(%r{\Adata:(image/[\w.+-]+);base64,(.+)\z}m)

    unless match && ALLOWED_LOGO_CONTENT_TYPES.include?(match[1])
      return render json: { success: false, message: 'Unsupported or missing image' }, status: :unprocessable_entity
    end

    file_data = Base64.decode64(match[2])
    if file_data.bytesize > MAX_LOGO_SIZE
      return render json: { success: false, message: 'Image too large' }, status: :unprocessable_entity
    end

    filepath = Rails.root.join('public', 'images', "team_#{@team.id}.png")
    File.binwrite(filepath, file_data)

    render json: { success: true, message: 'Logo uploaded successfully' }
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
