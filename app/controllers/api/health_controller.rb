module Api
  class HealthController < ApplicationController
    skip_forgery_protection

    def index
      render plain: 'ok'
    end
  end
end
