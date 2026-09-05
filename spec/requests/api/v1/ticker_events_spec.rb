require "swagger_helper"

RSpec.describe "api/v1/ticker_events", type: :request do
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
  let!(:player) { Player.create!(name: "Manuel Neuer", age: 38, position: "Torwart", number: 1, team: team_home) }
  let!(:ticker_event) { TickerEvent.create!(ticker: ticker, user: current_user, minute: "01:00", event_type: 0) }

  before { log_in(current_user, password: password) }

  path "/api/v1/ticker_events" do
    get("list ticker events") do
      tags "TickerEvents"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create ticker event") do
      tags "TickerEvents"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_event_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker_event: {
            type: :object,
            properties: {
              ticker_id: { type: :integer },
              minute: { type: :string, description: "Format MM:SS, z. B. '45:00'" },
              user_id: { type: :integer },
              event_type: { type: :integer },
              player_id: { type: :integer, nullable: true },
              fk_player1_id: { type: :integer, nullable: true },
              fk_player2_id: { type: :integer, nullable: true }
            },
            required: %w[ticker_id minute user_id]
          }
        }
      }

      response(201, "erstellt") do
        # A separate ticker avoids colliding with the (ticker_id, event_id) uniqueness
        # constraint on the ticker_event created above (event_id is always nil here,
        # since the controller doesn't currently permit it).
        let!(:other_ticker) { Ticker.create!(game: game, user: current_user, ticker_state: :first_half) }
        let(:ticker_event_params) do
          {
            ticker_event: {
              ticker_id: other_ticker.id,
              minute: "12:34",
              user_id: current_user.id,
              event_type: 1,
              player_id: player.id
            }
          }
        end
        run_test!
      end

      response(422, "ungültige Eingabe (z. B. falsches Minuten-Format)") do
        let(:ticker_event_params) do
          { ticker_event: { ticker_id: ticker.id, minute: "invalid", user_id: current_user.id } }
        end
        run_test!
      end
    end
  end

  path "/api/v1/ticker_events/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Ticker-Event-ID"

    get("show ticker event") do
      tags "TickerEvents"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { ticker_event.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update ticker event") do
      tags "TickerEvents"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_event_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker_event: {
            type: :object,
            properties: {
              minute: { type: :string },
              event_type: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { ticker_event.id }
        let(:ticker_event_params) { { ticker_event: { event_type: 2 } } }
        run_test!
      end
    end

    put("replace ticker event") do
      tags "TickerEvents"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :ticker_event_params, in: :body, schema: {
        type: :object,
        properties: {
          ticker_event: {
            type: :object,
            properties: {
              minute: { type: :string },
              event_type: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { ticker_event.id }
        let(:ticker_event_params) { { ticker_event: { event_type: 2 } } }
        run_test!
      end
    end

    delete("delete ticker event") do
      tags "TickerEvents"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { ticker_event.id }
        run_test!
      end
    end
  end
end
