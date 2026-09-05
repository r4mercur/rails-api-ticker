require "swagger_helper"

RSpec.describe "api/v1/tickers", type: :request do
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
  let!(:ticker) { Ticker.create!(game: game, user: current_user, ticker_state: :not_started) }

  before { log_in(current_user, password: password) }

  path "/api/v1/tickers" do
    get("list tickers") do
      tags "Tickers"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create ticker") do
      tags "Tickers"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker: {
            type: :object,
            properties: {
              game_id: { type: :integer },
              user_id: { type: :integer },
              ticker_state: {
                type: :integer,
                description: "0=not_started, 1=first_half, 2=second_half, 3=third_half, 4=fourth_half, 5=ended, 999=half_time"
              }
            },
            required: %w[game_id user_id]
          }
        }
      }

      response(201, "erstellt") do
        let(:ticker_params) { { ticker: { game_id: game.id, user_id: current_user.id, ticker_state: 0 } } }
        run_test!
      end

      response(422, "ungültige Eingabe") do
        let(:ticker_params) { { ticker: { game_id: nil, user_id: nil } } }
        run_test!
      end
    end
  end

  path "/api/v1/tickers/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Ticker-ID"

    get("show ticker") do
      tags "Tickers"
      security [cookieAuth: []]
      description "Liefert den Ticker inklusive Spiel, beider Teams samt Spielern und aller Ticker-Events."
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { ticker.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update ticker") do
      tags "Tickers"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker: {
            type: :object,
            properties: {
              ticker_state: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { ticker.id }
        let(:ticker_params) { { ticker: { ticker_state: 1 } } }
        run_test!
      end
    end

    put("replace ticker") do
      tags "Tickers"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker: {
            type: :object,
            properties: {
              ticker_state: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { ticker.id }
        let(:ticker_params) { { ticker: { ticker_state: 1 } } }
        run_test!
      end
    end

    delete("delete ticker") do
      tags "Tickers"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { ticker.id }
        run_test!
      end
    end
  end

  path "/api/v1/users/{id}/tickers" do
    parameter name: :id, in: :path, type: :integer, description: "User-ID"

    get("list tickers for a user") do
      tags "Tickers"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { current_user.id }
        run_test!
      end
    end
  end
end
