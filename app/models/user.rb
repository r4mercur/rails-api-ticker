class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  def as_json(options = {})
    super(options.merge(except: Array(options[:except]) + [:password_digest]))
  end
end
