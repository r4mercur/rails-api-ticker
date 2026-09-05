class ApplicationController < ActionController::API
  ALLOWED_ORIGINS = %w[http://localhost:5173 http://127.0.0.1:5173].freeze

  before_action :verify_origin!
  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  # Cookie-based sessions have no CSRF token in an API-only app, so unsafe
  # requests are only trusted when they come from a known frontend origin.
  def verify_origin!
    return if request.get? || request.head?

    origin = request.headers['Origin']
    head :forbidden unless origin && ALLOWED_ORIGINS.include?(origin)
  end

  def require_login
    head :unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Opt-in pagination: without a `page` param the full collection is returned
  # exactly as before, so existing index responses stay a plain JSON array.
  def paginate(scope)
    return scope unless params[:page].present?

    per_page = (params[:per_page] || 25).to_i.clamp(1, 100)
    paginated = scope.page(params[:page]).per(per_page)
    set_pagination_headers(paginated, per_page)
    paginated
  end

  def set_pagination_headers(paginated, per_page)
    response.set_header('X-Total-Count', paginated.total_count.to_s)
    response.set_header('X-Total-Pages', paginated.total_pages.to_s)
    response.set_header('X-Page', paginated.current_page.to_s)

    links = []
    if paginated.prev_page
      links << %(<#{request.base_url}#{request.path}?page=#{paginated.prev_page}&per_page=#{per_page}>; rel="prev")
    end
    if paginated.next_page
      links << %(<#{request.base_url}#{request.path}?page=#{paginated.next_page}&per_page=#{per_page}>; rel="next")
    end
    response.set_header('Link', links.join(', ')) if links.any?
  end
end
