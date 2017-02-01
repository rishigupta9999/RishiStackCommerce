require 'test_helper'

class TwitterControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  
  test "should get view tweet page" do

    @user = User.create(:email => "#{rand(50000)}@example.com")
    sign_in @user

    get twitter_view_tweet_url
    assert_response :success
  end

  test "should get redirected" do
    get twitter_view_tweet_url
    assert_response :redirect
  end

end
