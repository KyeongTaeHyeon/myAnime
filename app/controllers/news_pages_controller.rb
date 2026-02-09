class NewsPagesController < ApplicationController
  def index
    scope = NewsArticle.search(params[:q]).order(published_at: :desc, created_at: :desc)
    @page = paginate(scope)
    @articles = @page[:content]
  end
end
