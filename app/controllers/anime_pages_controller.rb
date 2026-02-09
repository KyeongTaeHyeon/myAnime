class AnimePagesController < ApplicationController
  def index
    scope = Anime.search(params[:q]).order(season_year: :desc, created_at: :desc)
    @page = paginate(scope, default_size: 24)
    @anime_list = @page[:content]
    @liked_ids = []
    if current_user && @anime_list.any?
      @liked_ids = AnimeLike.where(user_id: current_user.id, anime_id: @anime_list.map(&:id)).pluck(:anime_id)
    end
  end

  def show
    @anime = Anime.find(params[:id])
    @liked = current_user ? AnimeLike.exists?(user_id: current_user.id, anime_id: @anime.id) : false
    @like_count = AnimeLike.where(anime_id: @anime.id).count
    @quotes = Quote.where(anime_id: @anime.id).order(created_at: :desc).limit(10)
  rescue ActiveRecord::RecordNotFound
    redirect_to anime_path, alert: '애니를 찾을 수 없습니다.'
  end
end
