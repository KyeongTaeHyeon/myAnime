class Anime < ApplicationRecord
  has_many :quotes, dependent: :nullify
  has_many :anime_likes, dependent: :destroy

  validates :anilist_id, presence: true, uniqueness: true

  scope :search, ->(q) {
    return all if q.blank?

    like = "%#{q}%"
    where('title_romaji LIKE :q OR title_english LIKE :q OR title_native LIKE :q', q: like)
  }
end
