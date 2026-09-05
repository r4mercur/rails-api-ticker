module AuthHelper
  # Cookie-session auth: log in through the real endpoint so the session
  # cookie set on the test's Rack session is valid for the request under test.
  def log_in(user, password:)
    post "/api/v1/login",
         params: { email: user.email, password: password },
         headers: { "Origin" => "http://localhost:5173" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
