RSpec.xdescribe 'TagRegisteredTags', type: :request do
  describe 'GET /api/v1/tags/:id/registered_tags' do
    let(:tag) { create(:tag) }
    let(:tags_json) { json['registeredTags'] }
    let!(:tag_registered_tag) { create(:registered_tag, tag: tag) }
    let!(:other_registered_tag) { create(:registered_tag) }

    describe '全般的なこと' do
      before do
        create_list(:registered_tag, 10, tag: tag)
        get "/api/v1/tags/#{tag.id}/registered_tags"
      end
      it '200 OKを返す' do
        expect(response.status).to eq 200
      end
      it '指定のハッシュタグのregistered_tagのみ含む' do
        # expect(json['registeredTags']).to include tag_registered_tag.tag.name
        # expect(json['registeredTags']).not_to include other_registered_tag.tag.name
      end
      it 'Tag.registered_tagsのJSONを返す' do
        registered_tags = tag.registered_tags
        tags_json.zip(registered_tags).each do |tag_json, registered_tag|
          expect(tag_json).to eq({
            'id' => registered_tag.id,
            'tweetedDayCount' => registered_tag.tweeted_day_count,
            'privacy' => registered_tag.privacy_i18n,
            'remindDay' => registered_tag.remind_day,
            'firstTweetedAt' => registered_tag.first_tweeted_at,
            'lastTweetedAt' => registered_tag.last_tweeted_at,
            'tag' => {
              'id' => registered_tag.tag.id,
              'name' => registered_tag.tag.name,
            }
          })
        end
      end
      context 'registered_tagが限定公開のとき' do
        let(:limited_registered_tag) { create(:registered_tag, :limited, tag: tag) }
        it '含まない' do

        end
      end
      context 'registered_tagが非公開のとき' do
        let(:closed_registered_tag) { create(:registered_tag, :closed, tag: tag) }
        it '含まない' do
        end
      end
    end

    context 'countクエリがないとき' do
      describe 'pagy' do
        before do
          create_list(:registered_tag, 50, tag: tag)
          get "/api/v1/tags/#{tag.id}/registered_tags"
        end
        it 'pageクエリがないとき 20件返す' do
          expect(tags_json.length).to eq 20
        end
        it 'page=2のとき 20件返す' do
          get '/api/v1/tags?page=2'
          expect(tags_json.length).to eq 20
        end
      end
    end
    context 'countクエリがあるとき' do
      let(:count) { rand(1..5) }
      before do
        create_list(:registered_tag, 10, tag: tag)
        get "/api/v1/tags/#{tag.id}/registered_tags?count=#{count}"
      end
      it 'countで指定したレコード数を返す' do
        expect(tags_json.length).to eq count
      end
    end
  end
end
