Rswag::Ui.configure do |c|
  # Points the Swagger UI (served at /api-docs) at the generated OpenAPI file.
  c.openapi_endpoint "/api-docs/v1/swagger.yaml", "Ticker API V1"
end
