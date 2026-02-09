module Api
  class AuthController < ApplicationController
    skip_forgery_protection

    def register
      if User.exists?(email: register_params[:email].to_s.downcase)
        render json: { error: 'Email already registered' }, status: :conflict
        return
      end

      user = User.new(
        email: register_params[:email],
        display_name: register_params[:displayName],
        role: 'USER',
        password: register_params[:password],
        password_confirmation: register_params[:password]
      )

      unless user.save
        render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
        return
      end

      render json: auth_payload(user)
    end

    def login
      user = User.find_by(email: login_params[:email].to_s.downcase)
      if user.nil? || !user.authenticate(login_params[:password])
        render json: { error: 'Invalid credentials' }, status: :unauthorized
        return
      end

      render json: auth_payload(user)
    end

    def me
      if current_user.nil?
        render json: { ok: false }
        return
      end

      render json: {
        ok: true,
        id: current_user.id,
        email: current_user.email,
        displayName: current_user.display_name,
        role: current_user.role
      }
    end

    private

    def auth_payload(user)
      ttl_seconds = ENV.fetch('JWT_ACCESS_TTL_MIN', '60').to_i * 60
      now = Time.now.to_i
      token = JWT.encode({ sub: user.email, role: user.role, iat: now, exp: now + ttl_seconds }, jwt_secret, 'HS256')

      {
        accessToken: token,
        tokenType: 'Bearer',
        expiresIn: ttl_seconds
      }
    end

    def register_params
      params.permit(:email, :password, :displayName)
    end

    def login_params
      params.permit(:email, :password)
    end
  end
end
