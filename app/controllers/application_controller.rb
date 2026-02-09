class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private

  def jwt_secret
    ENV.fetch('JWT_SECRET', 'change_me_change_me_change_me_change_me')
  end

  def current_user
    return @current_user if defined?(@current_user)

    token = bearer_token
    return @current_user = nil if token.blank?

    payload, = JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
    email = payload['sub']
    @current_user = email ? User.find_by(email: email.downcase) : nil
  rescue StandardError
    @current_user = nil
  end

  def require_auth!
    return if current_user

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def bearer_token
    header = request.headers['Authorization'].to_s
    return nil unless header.start_with?('Bearer ')

    header.split(' ', 2).last
  end

  def paginate(scope, default_size: 20)
    page = params.fetch(:page, 0).to_i
    size = params.fetch(:size, default_size).to_i
    size = default_size if size <= 0
    page = 0 if page.negative?

    total = scope.count
    items = scope.limit(size).offset(page * size)
    total_pages = size.zero? ? 0 : (total.to_f / size).ceil

    {
      content: items,
      page: page,
      size: size,
      totalElements: total,
      totalPages: total_pages,
      numberOfElements: items.length,
      first: page.zero?,
      last: page + 1 >= total_pages
    }
  end
end
