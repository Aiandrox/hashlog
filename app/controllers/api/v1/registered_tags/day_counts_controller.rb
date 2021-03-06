require 'pagy/extras/array'

class Api::V1::RegisteredTags::DayCountsController < Api::V1::BaseController
  def index
    registered_tags = RegisteredTag.includes(:user, :tag).opened.have_tweets.day_count_sort
    @pagy, registered_tags = pagy_array(registered_tags)
    render json: registered_tags
  end
end
