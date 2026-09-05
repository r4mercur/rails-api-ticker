class Rack::Attack
  # Blunt brute-force login attempts: 5 tries per IP per 20 seconds.
  throttle('login attempts/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/api/v1/login' && req.post?
  end

  # General safety net so a single client can't hammer the API.
  throttle('requests/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  self.throttled_responder = lambda do |_request|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Too many requests, please try again later.' }.to_json]]
  end
end
