require 'test_helper'

class TwitterControllerTest < ActionDispatch::IntegrationTest
  test "should get view_tweet" do
    get twitter_view_tweet_url
    assert_response :success
  end

end
