class Quote < ApplicationRecord
  belongs_to :anime, optional: true

  scope :search, ->(q) {
    return all if q.blank?

    like = "%#{q}%"
    where('quote_text LIKE :q OR character_name LIKE :q OR source LIKE :q', q: like)
  }
end
