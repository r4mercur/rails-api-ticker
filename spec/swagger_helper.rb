require "rails_helper"

RSpec.configure do |config|
  # Where rswag writes the generated OpenAPI file(s) (rake rswag:specs:swaggerize).
  # Also read by rswag-api (config/initializers/rswag_api.rb) to serve them at /api-docs.
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Ticker API V1",
        version: "v1",
        description: "API zur Verwaltung von Wettbewerben, Teams, Spielern, Spielen und Live-Tickern."
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Lokale Entwicklung"
        }
      ],
      components: {
        securitySchemes: {
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: "_ticker_api_session",
            description: "Session-Cookie, das nach POST /api/v1/login gesetzt wird. Alle Endpunkte außer Login/Registrierung erfordern eine eingeloggte Session."
          }
        }
      }
    }
  }

  # Generate the docs as YAML (matches the rswag_ui.rb endpoint path above).
  config.openapi_format = :yaml
end
