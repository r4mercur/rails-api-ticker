require "swagger_helper"

RSpec.describe "api/v1/teams", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }
  let!(:team) { Team.create!(name: "FC Bayern", shortname: "FCB") }

  # A minimal valid 1x1 px PNG, used as a realistic upload payload.
  let(:tiny_png_base64) { "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=" }

  before { log_in(current_user, password: password) }

  path "/api/v1/teams" do
    get("list teams") do
      tags "Teams"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl (aktiviert Pagination)"
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25)"

      response(200, "erfolgreich") { run_test! }
    end

    post("create team") do
      tags "Teams"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string },
              shortname: { type: :string }
            },
            required: %w[name]
          },
          competition_id: {
            type: :integer,
            nullable: true,
            description: "Optional: legt zusätzlich eine Participation an, die das Team diesem Wettbewerb zuordnet."
          }
        }
      }

      response(201, "erstellt") do
        let(:body) { { team: { name: "Borussia Dortmund", shortname: "BVB" } } }
        run_test!
      end

      response(422, "ungültige Eingabe") do
        let(:body) { { team: { name: nil } } }
        run_test!
      end
    end
  end

  path "/api/v1/teams/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Team-ID"

    get("show team") do
      tags "Teams"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        let(:id) { team.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update team") do
      tags "Teams"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :team_params, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string },
              shortname: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { team.id }
        let(:team_params) { { team: { shortname: "FCB2" } } }
        run_test!
      end
    end

    put("replace team") do
      tags "Teams"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :team_params, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string },
              shortname: { type: :string }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        let(:id) { team.id }
        let(:team_params) { { team: { shortname: "FCB2" } } }
        run_test!
      end
    end

    delete("delete team") do
      tags "Teams"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        let(:id) { team.id }
        run_test!
      end
    end
  end

  path "/api/v1/teams/{id}/upload_logo" do
    parameter name: :id, in: :path, type: :integer, description: "Team-ID"

    post("upload team logo") do
      tags "Teams"
      security [cookieAuth: []]
      description "Nimmt ein Bild als Base64-Data-URI entgegen (png/jpeg/webp, max. 5 MB) und speichert es " \
                   "immer als public/images/team_<id>.png, unabhängig vom Quellformat."
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          logo: {
            type: :string,
            description: "Base64-Data-URI, z. B. 'data:image/png;base64,...'"
          }
        },
        required: %w[logo]
      }

      # The controller writes to public/images/team_<id>.png regardless of Rails.env,
      # so without this the spec would clobber a real logo that happens to share the
      # test team's id. Back it up and restore it (or remove it) after each example.
      around do |example|
        filepath = Rails.root.join("public", "images", "team_#{team.id}.png")
        original = File.binread(filepath) if File.exist?(filepath)
        example.run
        if original
          File.binwrite(filepath, original)
        else
          File.delete(filepath) if File.exist?(filepath)
        end
      end

      response(200, "erfolgreich hochgeladen") do
        let(:id) { team.id }
        let(:body) { { logo: "data:image/png;base64,#{tiny_png_base64}" } }
        run_test!
      end

      response(422, "ungültiges oder zu großes Bild") do
        let(:id) { team.id }
        let(:body) { { logo: "not-a-data-uri" } }
        run_test!
      end
    end
  end
end
