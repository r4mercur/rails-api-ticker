Rswag::Api.configure do |c|
  # Serves the generated OpenAPI file(s) below from /api-docs.
  c.openapi_root = Rails.root.join("swagger").to_s

  # Rewrite the "servers" block in the served document to match the request host,
  # e.g. so /api-docs works the same behind different hostnames/proxies.
  # c.openapi_filter = lambda { |doc, request| doc }
end
