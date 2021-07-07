class Api::V1::TagRegisteredTagsController < Api::V1::BaseController
  # TODO: 同じハッシュタグのregistered_tagsを返す。テストも書けていない。
  def index
    tag = Tag.find(params[:tag_id])
    registered_tags = tag.registered_tags.published
    if (count = params[:count])
      registered_tags.limit!(count)
    else
      @pagy, registered_tags = pagy(registered_tags)
    end
    render json: registered_tags
    # user.nameを含む。自らのリソース（RegisteredTag.find_by(tag_id: tag.id)）は含まない
  end
end
