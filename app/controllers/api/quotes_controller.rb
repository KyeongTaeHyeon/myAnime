module Api
  class QuotesController < ApplicationController
    skip_forgery_protection

    def index
      scope = Quote.search(params[:q]).order(created_at: :desc)
      page = paginate(scope)
      page[:content] = page[:content].map do |quote|
        {
          id: quote.id,
          source: quote.source,
          characterName: quote.character_name,
          quoteText: quote.quote_text
        }
      end

      render json: page
    end
  end
end
