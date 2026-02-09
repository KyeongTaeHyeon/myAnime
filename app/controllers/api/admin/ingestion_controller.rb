module Api
  module Admin
    class IngestionController < ApplicationController
      skip_forgery_protection
      before_action :require_auth!

      def season
        saved = AnilistIngestionService.ingest_season(
          year: params.fetch(:year),
          season: params.fetch(:season),
          page: params.fetch(:page, 1),
          per_page: params.fetch(:perPage, 50)
        )

        render json: {
          provider: 'anilist',
          saved: saved,
          at: Time.current.iso8601
        }
      end

      def quotes
        saved = AnimechanIngestionService.ingest_quotes(anime_name: params.fetch(:anime))
        render json: {
          provider: 'animechan',
          saved: saved,
          at: Time.current.iso8601
        }
      end

      def news
        saved = NewsIngestionService.ingest_news(query: params[:query], language: params[:language])
        render json: {
          provider: 'newsapi',
          saved: saved,
          at: Time.current.iso8601
        }
      end

      def status
        render json: IngestionState.order(:provider)
      end

      def all
        anime_saved = nil
        quotes_saved = nil
        news_saved = 0
        anime_error = nil
        quotes_error = nil
        news_error = nil

        begin
          anime_saved = AnilistIngestionService.ingest_season(
            year: ENV.fetch('INGESTION_ANILIST_YEAR', '2025'),
            season: ENV.fetch('INGESTION_ANILIST_SEASON', 'WINTER'),
            page: ENV.fetch('INGESTION_ANILIST_PAGE', '1'),
            per_page: ENV.fetch('INGESTION_ANILIST_PER_PAGE', '50')
          )
        rescue StandardError => e
          anime_error = e.message
        end

        quotes_anime = ENV['INGESTION_QUOTES_ANIME'].to_s
        if quotes_anime.blank?
          quotes_error = 'INGESTION_QUOTES_ANIME is not configured'
        else
          begin
            quotes_saved = AnimechanIngestionService.ingest_quotes(anime_name: quotes_anime)
          rescue StandardError => e
            quotes_error = e.message
          end
        end

        languages = parse_languages(ENV.fetch('NEWS_API_LANGUAGE', 'en'))
        languages = [nil] if languages.empty?
        news_errors = []
        query = ENV['INGESTION_NEWS_QUERY']

        languages.each do |language|
          begin
            news_saved += NewsIngestionService.ingest_news(query: query, language: language)
          rescue StandardError => e
            label = language.presence || 'default'
            news_errors << "#{label}: #{e.message}"
          end
        end
        news_error = news_errors.join(' | ') if news_errors.any?

        render json: {
          provider: 'all',
          animeSaved: anime_saved,
          quotesSaved: quotes_saved,
          newsSaved: news_saved,
          animeError: anime_error,
          quotesError: quotes_error,
          newsError: news_error,
          newsEndpoint: ENV.fetch('NEWS_API_ENDPOINT', 'https://newsapi.org/v2/everything'),
          newsLanguageRaw: ENV.fetch('NEWS_API_LANGUAGE', 'en'),
          newsLanguages: languages,
          at: Time.current.iso8601
        }
      end

      private

      def parse_languages(raw)
        raw.to_s.gsub(/\bOR\b/i, ',').split(/[\s,]+/).map(&:strip).reject(&:blank?)
      end
    end
  end
end
