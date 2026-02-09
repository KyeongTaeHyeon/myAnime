class NewsArticle < ApplicationRecord
  scope :search, ->(q) {
    return all if q.blank?

    like = "%#{q}%"
    where('title LIKE :q OR description LIKE :q', q: like)
  }
end
