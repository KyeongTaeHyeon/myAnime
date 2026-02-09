class User < ApplicationRecord
  self.table_name = 'app_users'

  has_secure_password
  has_many :anime_likes, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: :password

  before_validation do
    self.email = email.to_s.strip.downcase
  end
end
