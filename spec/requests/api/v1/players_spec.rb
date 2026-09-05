require "swagger_helper"

RSpec.describe "api/v1/players", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }
  let!(:team) { Team.create!(name: "FC Bayern", shortname: "FCB") }
  let!(:player) { Player.create!(name: "Manuel Neuer", age: 38, position: "Torwart", number: 1, team: team) }

  before { log_in(current_user, password: password) }

  path "/api/v1/players" do
    get("list players") do
      tags "Players"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create player") do
      tags "Players"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :player_params, in: :body, schema: {
        type: :object,
        properties: {
          player: {
            type: :object,
            properties: {
              name: { type: :string },
              age: { type: :integer },
              position: { type: :string },
              number: { type: :integer },
              team_id: { type: :integer }
            },
            required: %w[name team_id]
          }
        }
      }

      response(201, "erstellt") do
        let(:player_params) { { player: { name: "Joshua Kimmich", age: 30, position: "Mittelfeld", number: 6, team_id: team.id } } }
        run_test!
      end

      response(422, "ungültige Eingabe") do
        let(:player_params) { { player: { name: nil, team_id: nil } } }
        run_test!
      end
    end
  end

  path "/api/v1/players/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Spieler-ID"

    get("show player") do
      tags "Players"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { player.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update player") do
      tags "Players"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :player_params, in: :body, schema: {
        type: :object,
        properties: {
          player: {
            type: :object,
            properties: {
              name: { type: :string },
              age: { type: :integer },
              position: { type: :string },
              number: { type: :integer },
              team_id: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { player.id }
        let(:player_params) { { player: { number: 27 } } }
        run_test!
      end
    end

    put("replace player") do
      tags "Players"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :player_params, in: :body, schema: {
        type: :object,
        properties: {
          player: {
            type: :object,
            properties: {
              name: { type: :string },
              age: { type: :integer },
              position: { type: :string },
              number: { type: :integer },
              team_id: { type: :integer }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { player.id }
        let(:player_params) { { player: { number: 27 } } }
        run_test!
      end
    end

    delete("delete player") do
      tags "Players"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { player.id }
        run_test!
      end
    end
  end
end
