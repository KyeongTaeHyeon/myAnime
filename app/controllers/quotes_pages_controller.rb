class QuotesPagesController < ApplicationController
  def index
    scope = Quote.search(params[:q]).order(created_at: :desc)
    @page = paginate(scope)
    @quotes = @page[:content]
  end
end
