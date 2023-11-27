class Player < ApplicationRecord
  belongs_to :team

  def self.search(search)
    if search
      where(["name LIKE ?","%#{search}%"])
    else
      all
    end
  end
end
