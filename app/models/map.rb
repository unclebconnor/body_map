class Map < ApplicationRecord
  belongs_to :user
  has_many :annotations
end
