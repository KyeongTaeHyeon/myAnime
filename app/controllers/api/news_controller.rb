module Api
  class NewsController < ApplicationController
    skip_forgery_protection

    def index
      scope = NewsArticle.search(params[:q]).order(published_at: :desc, created_at: :desc)
      page = paginate(scope)
      page[:content] = page[:content].map do |article|
        {
          id: article.id,
          provider: article.provider,
          title: article.title,
          description: article.description,
          url: article.url,
          imageUrl: article.image_url
        }
      end

      render json: page
    end
  end
end
