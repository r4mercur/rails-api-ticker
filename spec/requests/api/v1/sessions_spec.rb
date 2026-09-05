require "swagger_helper"

RSpec.describe "api/v1/login", type: :request do
  let(:password) { "password123" }
  let!(:user) { User.create!(email: "demo@example.com", username: "demo", password: password, password_confirmation: password) }

  path "/api/v1/login" do
    post("log in") do
      tags "Sessions"
      description "Startet eine Cookie-Session. Das Session-Cookie wird per Set-Cookie-Header gesetzt " \
                   "und muss vom Client bei Folge-Requests automatisch mitgeschickt werden (credentials: 'include')."
      consumes "application/json"
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, format: :password }
        },
        required: %w[email password]
      }

      response(200, "erfolgreich eingeloggt") do
        let(:credentials) { { email: user.email, password: password } }
        run_test!
      end

      response(401, "ungültige Zugangsdaten") do
        let(:credentials) { { email: user.email, password: "wrong-password" } }
        run_test!
      end
    end
  end

  path "/api/v1/logout" do
    post("log out") do
      tags "Sessions"
      description "Beendet die aktuelle Session (setzt session[:user_id] zurück)."
      produces "application/json"
      parameter name: :Origin, in: :header, type: :string, required: true,
                description: "Muss einer erlaubten Frontend-Origin entsprechen (CSRF-Schutz, siehe ApplicationController#verify_origin!)."
      let(:Origin) { "http://localhost:5173" }

      response(200, "erfolgreich ausgeloggt") do
        run_test!
      end
    end
  end
end
