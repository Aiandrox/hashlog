class User < ApplicationRecord
  before_create :set_uuid

  authenticates_with_sorcery!
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications

  validates :twitter_id, presence: true, uniqueness: true
  validates :screen_name, presence: true, length: { maximum: 30 }
  validates :email, uniqueness: true # Twitterではメールアドレスは必須ではない
  validates :description, length: { maximum: 300 }
  validates :privacy, presence: true
  validates :role, presence: true

  enum privacy: { published: 0, closed: 1 }
  enum role: { admin: 0, general: 1, guest: 2 }

  def set_uuid
    self.uuid = loop do
      random_token = SecureRandom.urlsafe_base64(9)
      break random_token unless self.class.exists?(uuid: random_token)
    end
  end
end