class RegisteredTag < ApplicationRecord
  DAY_COUNT_MONTH = 30
  NONE = 0
  FULL = 1
  FULL_PER = 100
  USER_REGISTERED_TAGS_COUNT = 10
  [DAY_COUNT_MONTH, NONE, FULL, FULL_PER, USER_REGISTERED_TAGS_COUNT].each(&:freeze)

  before_validation :filter_remind_day

  has_many :tweets, dependent: :destroy
  belongs_to :user
  belongs_to :tag

  validates :privacy, presence: true
  validates :remind_day, numericality: { only_integer: true,
                                         less_than_or_equal_to: DAY_COUNT_MONTH }
  validates :tag_id, uniqueness: { scope: :user_id, message: 'は既に登録しています' }
  validate :user_registered_tags_count_validate, on: :create

  enum privacy: { published: 0, closed: 1, limited: 2 }

  scope :asc, -> { order(created_at: :asc) }
  scope :desc, -> { order(created_at: :desc) }
  scope :opened, -> { published.joins(:user).where('users.privacy = ?', 0) }
  scope :have_tweets, -> { where('first_tweeted_at < ?', Time.now) }

  def self.day_count_sort
    all.sort_by { |tag| [tag.tweeted_day_count, tag.tweet_rate] }.reverse
  end

  def self.persistence_sort
    all.sort_by { |tag| [tag.tweet_rate, tag.tweeted_day_count] }.reverse
  end

  def last_tweeted_at
    @last_tweeted_at ||= tweets.latest&.tweeted_at
  end

  def tweeted_day_count
    @tweeted_day_count ||= tweets&.tweeted_day_count
  end

  def day_from_last_tweet
    last_tweeted_at.nil? ? NONE : (Date.today - last_tweeted_at.to_date).to_i
  end

  def day_from_first_tweet
    first_tweeted_at.nil? ? NONE : (Date.today - first_tweeted_at.to_date).to_i + 1
  end

  def remind_reply?
    remind_day.positive? && remind_day < day_from_last_tweet && day_from_last_tweet < remind_day + 5
  end

  def tweet_rate
    return NONE if first_tweeted_at.nil?
    return FULL if (day_from_first_tweet - day_from_last_tweet).zero?

    # 今日のデータがない場合は昨日時点までのデータで計算する
    denominator = day_from_last_tweet.zero? ? day_from_first_tweet : day_from_first_tweet - 1
    (tweeted_day_count.to_f / denominator * FULL_PER).round(1)
  end

  def create_tweets(tweets_data_array)
    add_tweets(tweets_data_array).any? && fetch_tweets_data!
  end

  def add_tweets(tweets_data_array)
    tweets_data_array.each do |oembed, tweeted_at, tweet_id, medias|
      tweets.create_with_images!(
        oembed: oembed,
        tweeted_at: tweeted_at,
        tweet_id: tweet_id,
        medias: medias
      )
    end
  end

  def fetch_tweets_data!
    update!(first_tweeted_at: tweets.oldest.tweeted_at) if tweets.any?
  end

  private

  def filter_remind_day
    self.remind_day = NONE if remind_day.nil?
  end

  def user_registered_tags_count_validate
    return unless user&.registered_tags&.count.to_d >= USER_REGISTERED_TAGS_COUNT

    errors.add(:base, "登録できるハッシュタグは#{USER_REGISTERED_TAGS_COUNT}個までです")
  end
end
