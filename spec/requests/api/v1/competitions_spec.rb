require "swagger_helper"

RSpec.describe "api/v1/competitions", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }
  let!(:competition) { Competition.create!(name: "Bundesliga") }

  before { log_in(current_user, password: password) }

  path "/api/v1/competitions" do
    get("list competitions") do
      tags "Competitions"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create competition") do
      tags "Competitions"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :competition_params, in: :body, schema: {
        type: :object,
        properties: {
          competition: {
            type: :object,
            properties: {
              name: { type: :string },
              type: { type: :string, description: "STI-Typ, falls verwendet" }
            },
            required: %w[name]
          }
        }
      }

      response(201, "erstellt") do
        let(:competition_params) { { competition: { name: "Champions League" } } }
        run_test!
      end

      response(422, "ungültige Eingabe") do
        let(:competition_params) { { competition: { name: nil } } }
        run_test!
      end
    end
  end

  path "/api/v1/competitions/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Wettbewerb-ID"

    get("show competition") do
      tags "Competitions"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { competition.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update competition") do
      tags "Competitions"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :competition_params, in: :body, schema: {
        type: :object,
        properties: {
          competition: {
            type: :object,
            properties: {
              name: { type: :string },
              type: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { competition.id }
        let(:competition_params) { { competition: { name: "Bundesliga 2" } } }
        run_test!
      end
    end

    put("replace competition") do
      tags "Competitions"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :competition_params, in: :body, schema: {
        type: :object,
        properties: {
          competition: {
            type: :object,
            properties: {
              name: { type: :string },
              type: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { competition.id }
        let(:competition_params) { { competition: { name: "Bundesliga 2" } } }
        run_test!
      end
    end

    delete("delete competition") do
      tags "Competitions"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { competition.id }
        run_test!
      end
    end
  end

  path "/api/v1/competitions/{id}/teams" do
    parameter name: :id, in: :path, type: :integer, description: "Wettbewerb-ID"

    get("list teams in competition") do
      tags "Competitions"
      security [cookieAuth: []]
      produces "application/json"
      description "Alle Teams, die über eine Participation an diesem Wettbewerb teilnehmen."

      response(200, "erfolgreich") do
        let!(:team) { Team.create!(name: "FC Bayern", shortname: "FCB") }
        let!(:participation) { Participation.create!(team: team, competition: competition) }
        let(:id) { competition.id }
        run_test!
      end
    end
  end

  path "/api/v1/competitions/{id}/games" do
    parameter name: :id, in: :path, type: :integer, description: "Wettbewerb-ID"

    get("list games in competition") do
      tags "Competitions"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { competition.id }
        run_test!
      end
    end
  end

  path "/api/v1/competitions/{id}/games/{game_day}" do
    parameter name: :id, in: :path, type: :integer, description: "Wettbewerb-ID"
    parameter name: :game_day, in: :path, type: :integer, description: "Spieltag"

    get("list games on a matchday") do
      tags "Competitions"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { competition.id }
        let(:game_day) { 1 }
        run_test!
      end
    end
  end
end
