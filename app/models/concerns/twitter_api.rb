require 'twitter'

module TwitterAPI
  extend ActiveSupport::Concern

  included do
    # attr_reader :client

    def tweets_data(tweet_oembeds = [])
      tweet_ids = search_result('standard')[:tweet_ids]
      tweeted_ats = search_result('standard')[:tweeted_ats]
      client.oembeds(tweet_ids,
                    omit_script: true,
                    hide_thread: true,
                    lang: :ja).take(100).map do |oembed|
        tweet_oembeds << oembed.html
      end
      tweet_oembeds.zip(tweeted_ats)
    end

    def search_result(type)
      if type == 'standard'
        standard_search
      elsif type == '30day'
        premium_search
      end
    end

    # registered_tag用
    def standard_search(tweet_ids = [], tweeted_ats = [])
      @standard_search ||= begin
        client.search("##{tag.name} from:#{user.screen_name}",
                      result_type: 'recent').take(100).map do |result|
          tweeted_ats << result.created_at
          tweet_ids << result.id
        end
        @standard_search = { tweeted_ats: tweeted_ats, tweet_ids: tweet_ids }
      end
    end

    def premium_search(tweet_ids = [], tweeted_ats = [])
      @premium_search ||= begin
        client.premium_search("##{tag.name} from:#{user.screen_name}",
                              { maxResults: 100 },
                              { product: '30day' }).take(100).map do |result|
          tweeted_ats << result.created_at
          tweet_ids << result.id
        end
        @premium_search = { tweeted_ats: tweeted_ats, tweet_ids: tweet_ids }
      end
    end

    def client
      @client ||= begin
        Twitter::REST::Client.new do |config|
          config.consumer_key        = Rails.application.credentials.twitter[:key]
          config.consumer_secret     = Rails.application.credentials.twitter[:secret_key]
          config.access_token        = Rails.application.credentials.twitter[:access_token]
          config.access_token_secret = Rails.application.credentials.twitter[:access_token_secret]
          config.dev_environment     = 'dev'
        end
      end
    end
  end
end
