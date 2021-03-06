User.seed(
  id: 3,
  twitter_id: 'none',
  screen_name: 'hash1og',
  name: 'テストユーザー',
  description: "テスト",
  privacy: :published,
  role: :general,
  avatar_url: 'https://pbs.twimg.com/profile_images/1267362108703817728/bSK1Ux-E.jpg'
)

Tag.seed(
  id: 1,
  name: 'Hashlog',
)

RegisteredTag.seed(
  id: 1,
  user_id: 3,
  tag_id: 1,
)

30.times do |n|
  num = n + 1
  Tweet.seed(
    id: num,
    oembed: "#{num}<br>test_text<br>testtest<br>aaaaa",
    tweet_id: num,
    tweeted_at: num.days.ago,
    registered_tag_id: 1,
  )
end
