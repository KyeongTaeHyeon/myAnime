class IngestionState < ApplicationRecord
  validates :provider, presence: true, uniqueness: true
end
