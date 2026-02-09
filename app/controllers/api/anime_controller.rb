module Api
  class AnimeController < ApplicationController
    skip_forgery_protection

    def index
      scope = Anime.search(params[:q]).order(season_year: :desc, created_at: :desc)
      page = paginate(scope)
      page[:content] = page[:content].map { |anime| serialize_anime(anime) }
      render json: page
    end

    def show
      anime = Anime.find(params[:id])
      render json: serialize_anime(anime)
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Not found' }, status: :not_found
    end

    private

    def serialize_anime(anime)
      {
        id: anime.id,
        anilistId: anime.anilist_id,
        titleRomaji: anime.title_romaji,
        titleEnglish: anime.title_english,
        titleNative: anime.title_native,
        season: anime.season,
        seasonYear: anime.season_year,
        coverImageUrl: anime.cover_image_url
      }
    end
  end
end
