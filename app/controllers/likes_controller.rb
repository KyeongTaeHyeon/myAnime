class LikesController < ApplicationController
  before_action :require_web_auth!

  def create
    anime = Anime.find(params[:id])
    AnimeLike.find_or_create_by!(user_id: current_user.id, anime_id: anime.id)
    redirect_back fallback_location: anime_page_path(anime), notice: '좋아요를 눌렀습니다.'
  rescue ActiveRecord::RecordNotFound
    redirect_to anime_path, alert: '애니를 찾을 수 없습니다.'
  end

  def destroy
    AnimeLike.where(user_id: current_user.id, anime_id: params[:id]).delete_all
    redirect_back fallback_location: anime_page_path(params[:id]), notice: '좋아요를 취소했습니다.'
  end

  private

  def require_web_auth!
    return if current_user

    redirect_to login_path, alert: '로그인이 필요합니다.'
  end
end
