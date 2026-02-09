module Api
  class AnimeLikesController < ApplicationController
    skip_forgery_protection

    def status
      anime = Anime.find(params[:id])
      liked = current_user ? AnimeLike.exists?(user_id: current_user.id, anime_id: anime.id) : false
      count = AnimeLike.where(anime_id: anime.id).count
      render json: { liked: liked, count: count }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Anime not found' }, status: :not_found
    end

    def create
      require_auth!
      return if performed?

      anime = Anime.find(params[:id])
      AnimeLike.find_or_create_by!(user_id: current_user.id, anime_id: anime.id)
      count = AnimeLike.where(anime_id: anime.id).count
      render json: { liked: true, count: count }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Anime not found' }, status: :not_found
    end

    def destroy
      require_auth!
      return if performed?

      AnimeLike.where(user_id: current_user.id, anime_id: params[:id]).delete_all
      count = AnimeLike.where(anime_id: params[:id]).count
      render json: { liked: false, count: count }
    end

    def index
      require_auth!
      return if performed?

      scope = AnimeLike.includes(:anime).where(user_id: current_user.id).order(created_at: :desc)
      page = paginate(scope)
      page[:content] = page[:content].map do |like|
        {
          anime: {
            id: like.anime.id,
            anilistId: like.anime.anilist_id,
            titleRomaji: like.anime.title_romaji,
            titleEnglish: like.anime.title_english,
            titleNative: like.anime.title_native,
            season: like.anime.season,
            seasonYear: like.anime.season_year,
            coverImageUrl: like.anime.cover_image_url
          },
          likedAt: like.created_at
        }
      end

      render json: page
    end
  end
end
