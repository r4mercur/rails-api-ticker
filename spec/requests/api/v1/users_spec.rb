require "swagger_helper"

RSpec.describe "api/v1/users", type: :request do
  let(:password) { "password123" }
  let!(:current_user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }

  path "/api/v1/users" do
    get("list users") do
      tags "Users"
      security [cookieAuth: []]
      produces "application/json"
      parameter name: :page, in: :query, type: :integer, required: false, description: "Seitenzahl. Ohne diesen Parameter wird die volle, unpaginierte Liste zurückgegeben."
      parameter name: :per_page, in: :query, type: :integer, required: false, description: "Einträge pro Seite (1-100, Standard 25). Nur wirksam zusammen mit page."

      response(200, "erfolgreich") do
        before { log_in(current_user, password: password) }
        run_test!
      end

      response(401, "nicht eingeloggt") do
        run_test!
      end
    end

    post("create user") do
      tags "Users"
      description "Registrierung – einzige öffentlich erreichbare User-Aktion neben Login."
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              username: { type: :string },
              password: { type: :string, format: :password },
              password_confirmation: { type: :string, format: :password }
            },
            required: %w[email username password password_confirmation]
          }
        }
      }

      response(201, "user erstellt") do
        let(:user) do
          { user: { email: "new-user@example.com", username: "new-user", password: "password123", password_confirmation: "password123" } }
        end
        run_test! do
          # Registration logs the user in server-side too, just like /login does.
          expect(session[:user_id]).to eq(User.find_by(email: "new-user@example.com").id)
        end
      end

      response(422, "ungültige Eingabe") do
        let(:user) { { user: { email: "", username: "", password: "a", password_confirmation: "b" } } }
        run_test!
      end
    end
  end

  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "User-ID"

    get("show user") do
      tags "Users"
      security [cookieAuth: []]
      produces "application/json"

      response(200, "erfolgreich") do
        before { log_in(current_user, password: password) }
        let(:id) { current_user.id }
        run_test!
      end

      response(404, "nicht gefunden") do
        before { log_in(current_user, password: password) }
        let(:id) { 0 }
        run_test!
      end
    end

    patch("update user") do
      tags "Users"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              username: { type: :string },
              password: { type: :string, format: :password },
              password_confirmation: { type: :string, format: :password }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        before { log_in(current_user, password: password) }
        let(:id) { current_user.id }
        let(:user) { { user: { username: "demo-updated" } } }
        run_test!
      end
    end

    put("replace user") do
      tags "Users"
      security [cookieAuth: []]
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              username: { type: :string },
              password: { type: :string, format: :password },
              password_confirmation: { type: :string, format: :password }
            }
          }
        }
      }

      response(200, "erfolgreich aktualisiert") do
        before { log_in(current_user, password: password) }
        let(:id) { current_user.id }
        let(:user) { { user: { username: "demo-updated" } } }
        run_test!
      end
    end

    delete("delete user") do
      tags "Users"
      security [cookieAuth: []]
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(204, "gelöscht") do
        before { log_in(current_user, password: password) }
        let(:id) { current_user.id }
        run_test!
      end
    end
  end
end
