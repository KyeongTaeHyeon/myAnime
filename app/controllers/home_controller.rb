class HomeController < ApplicationController
  def index
    @latest_anime = Anime.order(season_year: :desc, created_at: :desc).limit(6)
    @latest_news = NewsArticle.order(published_at: :desc, created_at: :desc).limit(5)
    @latest_quotes = Quote.order(created_at: :desc).limit(5)
  end
end
