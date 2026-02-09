class LibraryController < ApplicationController
  before_action :require_web_auth!

  def index
    scope = AnimeLike.includes(:anime).where(user_id: current_user.id).order(created_at: :desc)
    @page = paginate(scope)
    @likes = @page[:content]
  end

  private

  def require_web_auth!
    return if current_user

    redirect_to login_path, alert: '로그인이 필요합니다.'
  end
end
