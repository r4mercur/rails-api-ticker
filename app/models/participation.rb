class Participation < ApplicationRecord
  belongs_to :team
  belongs_to :competition
end