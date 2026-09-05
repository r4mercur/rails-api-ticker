require "swagger_helper"

RSpec.describe "api/v1/games", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }
  let!(:competition) { Competition.create!(name: "Bundesliga") }
  let!(:team_home) { Team.create!(name: "FC Bayern", shortname: "FCB") }
  let!(:team_away) { Team.create!(name: "Borussia Dortmund", shortname: "BVB") }
  let!(:participation_home) { Participation.create!(team: team_home, competition: competition) }
  let!(:participation_away) { Participation.create!(team: team_away, competition: competition) }
  let!(:game) do
    Game.create!(
      competition: competition,
      team_home: team_home,
      team_away: team_away,
      match_day: 1,
      location: "Allianz Arena",
      date: DateTime.now
    )
  end

  before { log_in(current_user, password: password) }

  path "/api/v1/games" do
    get("list games") do
      tags "Games"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create game") do
      tags "Games"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :game_params, in: :body, schema: {
        type: :object,
        properties: {
          game: {
            type: :object,
            properties: {
              competition_id: { type: :integer },
              team_home_id: { type: :integer },
              team_away_id: { type: :integer },
              match_day: { type: :integer },
              location: { type: :string },
              date: { type: :string, format: "date-time" }
            },
            required: %w[competition_id team_home_id team_away_id match_day location date]
          }
        }
      }

      response(201, "erstellt") do
        let(:game_params) do
          {
            game: {
              competition_id: competition.id,
              team_home_id: team_home.id,
              team_away_id: team_away.id,
              match_day: 2,
              location: "Signal Iduna Park",
              date: DateTime.now.iso8601
            }
          }
        end
        run_test!
      end

      response(422, "ungültige Eingabe (z. B. gleiches Heim-/Auswärtsteam)") do
        let(:game_params) do
          {
            game: {
              competition_id: competition.id,
              team_home_id: team_home.id,
              team_away_id: team_home.id,
              match_day: 2,
              location: "Signal Iduna Park",
              date: DateTime.now.iso8601
            }
          }
        end
        run_test!
      end
    end
  end

  path "/api/v1/games/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Spiel-ID"

    get("show game") do
      tags "Games"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { game.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update game") do
      tags "Games"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :game_params, in: :body, schema: {
        type: :object,
        properties: {
          game: {
            type: :object,
            properties: {
              goals_home: { type: :integer },
              goals_away: { type: :integer },
              location: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { game.id }
        let(:game_params) { { game: { goals_home: 2, goals_away: 1 } } }
        run_test!
      end
    end

    put("replace game") do
      tags "Games"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :game_params, in: :body, schema: {
        type: :object,
        properties: {
          game: {
            type: :object,
            properties: {
              goals_home: { type: :integer },
              goals_away: { type: :integer },
              location: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { game.id }
        let(:game_params) { { game: { goals_home: 2, goals_away: 1 } } }
        run_test!
      end
    end

    delete("delete game") do
      tags "Games"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { game.id }
        run_test!
      end
    end
  end
end
