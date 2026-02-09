Rails.application.routes.draw do
  root 'home#index'
  get 'anime', to: 'anime_pages#index'
  get 'anime/:id', to: 'anime_pages#show', as: :anime_page
  post 'anime/:id/like', to: 'likes#create', as: :anime_like
  delete 'anime/:id/like', to: 'likes#destroy'

  get 'news', to: 'news_pages#index'
  get 'quotes', to: 'quotes_pages#index'
  get 'my/likes', to: 'library#index', as: :my_likes

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'register', to: 'registrations#new'
  post 'register', to: 'registrations#create'

  namespace :api do
    get 'health', to: 'health#index'

    post 'auth/register', to: 'auth#register'
    post 'auth/login', to: 'auth#login'
    get 'auth/me', to: 'auth#me'

    get 'anime', to: 'anime#index'
    get 'anime/likes', to: 'anime_likes#index'
    get 'anime/:id', to: 'anime#show'

    get 'anime/:id/like', to: 'anime_likes#status'
    post 'anime/:id/like', to: 'anime_likes#create'
    delete 'anime/:id/like', to: 'anime_likes#destroy'

    get 'news', to: 'news#index'
    get 'quotes', to: 'quotes#index'

    namespace :admin do
      scope :ingest do
        post 'anilist/season', to: 'ingestion#season'
        post 'animechan/quotes', to: 'ingestion#quotes'
        post 'newsapi', to: 'ingestion#news'
        post 'status', to: 'ingestion#status'
        post 'all', to: 'ingestion#all'
      end
    end
  end
end
