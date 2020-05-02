RSpec.describe RegisteredTag, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to have_many(:tweets).dependent(:destroy) }
  end

  describe 'validations' do
    before { create(:registered_tag) }
    it { is_expected.to validate_presence_of(:tweeted_day_count) }
    it { is_expected.to validate_presence_of(:privacy) }
    it { is_expected.to validate_presence_of(:remind_day) }
    it do
      is_expected.to(validate_uniqueness_of(:tag_id)
                    .scoped_to(:user_id)
                    .with_message('を既に登録しています'))
    end
  end

  describe 'default value' do
    let(:registered_tag) { create(:registered_tag) }
    it 'tweeted_day_countが0である' do
      expect(registered_tag.tweeted_day_count).to eq 0
    end
    it 'remind_dayが0である' do
      expect(registered_tag.tweeted_day_count).to eq 0
    end
    it 'privacyがpublishedである' do
      expect(registered_tag.published?).to be_truthy
    end
  end

  describe 'scopes' do
    describe 'desc' do
      let!(:latest_tag) { create(:registered_tag) }
      let!(:oldest_tag) { create(:registered_tag, :created_yesterday) }
      it 'create_atを基準に昇順に並ぶこと' do
        expect(RegisteredTag.desc.first).to eq latest_tag
        expect(RegisteredTag.desc.last).to eq oldest_tag
      end
    end
  end

  describe 'methods' do
    let(:user) { create(:user, :real_value) }
    describe '#create_tweets(type="standard")' do
      context 'ハッシュタグのツイートがTwitterに存在するとき' do
        let(:present_tag) do
          create(:registered_tag, user: user, tag: create(:tag, name: 'ポートフォリオ進捗'))
        end
        it '取得したツイートを保存する' do
          VCR.use_cassette('twitter_api/standard_search') do
            expect { present_tag.create_tweets }.to change(Tweet, :count).by(3)
          end
        end
      end
      context 'ハッシュタグのツイートがTwitterに存在しないとき' do
        let(:absent_tag) do
          create(:registered_tag, user: user, tag: create(:tag, name: 'absent_tag'))
        end
        it 'ツイートを取得しないので保存しない' do
          VCR.use_cassette('twitter_api/standard_search_with_absent_tag') do
            expect { absent_tag.create_tweets }.not_to change(Tweet, :count)
          end
        end
      end
    end

    describe '#add_tweets' do
      let(:tag) { create(:tag, name: 'ポートフォリオ進捗') }
      let(:registered_tag) { user.registered_tag(tag) }
      before 'タグ登録時にツイートを取得' do
        VCR.use_cassette('twitter_api/standard_search') do
          user.register_tag(tag)
        end
      end

      context '正常系 前日のツイートを取得したとき' do
        it '取得したツイートを保存する' do
          expect do
            VCR.use_cassette('twitter_api/everyday_search') do
              registered_tag.add_tweets
            end
          end.to change(Tweet, :count).by(1)
        end
        it '#fetch_data("add")を実行する' do
          expect(registered_tag).to receive(:fetch_data).with('add').once
          VCR.use_cassette('twitter_api/everyday_search') do
            registered_tag.add_tweets
          end
        end
        it 'ログを出力する' do
          expect(Rails.logger).to receive(:info).with('@aiandrox の #ポートフォリオ進捗 にツイートを追加')
          VCR.use_cassette('twitter_api/everyday_search') do
            registered_tag.add_tweets
          end
        end
      end

      context '既に前日のツイートを取得しているとき' do
        before { create(:tweet, :tweeted_yesterday, registered_tag: registered_tag) }
        it 'Twitter::Client#tweets_dataを実行しない' do
          client_mock = double('client mock')
          allow(client_mock).to receive(:tweets_data)
          allow(TwitterAPI::Client.new(registered_tag.user, registered_tag.tag)).to receive(:client).and_return(client_mock)
          expect(client_mock).not_to receive(:tweets_data)
          registered_tag.add_tweets
        end
      end

      context '前日のツイートがなかったとき' do
        it '#fetch_dataを実行しない' do
          expect(registered_tag).not_to receive(:fetch_data)
          VCR.use_cassette('twitter_api/everyday_search_none') do
            registered_tag.add_tweets
          end
        end
      end
      context 'ハッシュタグのツイートが1件も保存されていなかったとき' do
        before do
          registered_tag.tweets.each do |tweet|
            tweet.destroy
          end
        end
        it '#create_tweetsを実行する' do
          expect(registered_tag).to receive(:create_tweets).once
          VCR.use_cassette('twitter_api/standard_search') do
            registered_tag.add_tweets
          end
        end
      end
    end

    describe '#fetch_data(type="new")' do
      let(:registered_tag) { create(:registered_tag, :with_tweets) }
      let!(:oldest_tweet) { create(:tweet, :tweeted_7days_ago, registered_tag: registered_tag) }
      let(:latest_tweet) { registered_tag.tweets.latest }
      it 'tweet.first_tweetedが最初のツイート日時になる' do
        expect do
          registered_tag.fetch_data
        end.to change { registered_tag.first_tweeted_at }.from(nil).to(oldest_tweet.tweeted_at)
      end
      it 'tweet.last_tweetedが最後のツイート日時になる' do
        expect do
          registered_tag.fetch_data
        end.to change { registered_tag.last_tweeted_at }.from(nil).to(latest_tweet.tweeted_at)
      end
      it 'tweet.tweeted_day_countがツイートをした日数になる' do
        expect do
          registered_tag.fetch_data
        end.to change { registered_tag.tweeted_day_count }.from(0).to(2)
      end
      context 'type = "add"のとき' do
        it 'tweet.first_tweetedを更新しない' do
          expect do
            registered_tag.fetch_data('add')
          end.not_to change(registered_tag, :first_tweeted_at)
        end
      end
    end
  end
end
