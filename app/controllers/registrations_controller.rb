class RegistrationsController < ApplicationController
  def new; end

  def create
    @user = User.new(
      email: params[:email],
      display_name: params[:display_name],
      role: 'USER',
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: '회원가입이 완료되었습니다.'
      return
    end

    flash.now[:alert] = @user.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end
end
