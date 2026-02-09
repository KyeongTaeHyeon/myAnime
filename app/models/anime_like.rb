class AnimeLike < ApplicationRecord
  belongs_to :user
  belongs_to :anime

  validates :anime_id, uniqueness: { scope: :user_id }
end
