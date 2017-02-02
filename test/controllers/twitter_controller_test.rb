require 'test_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "vcr_cassettes"
  config.hook_into :faraday
end

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

  test "retrieve tweets" do
    @user = User.create(:email => "#{rand(50000)}@example.com")
    sign_in @user

    VCR.use_cassette('retrieve_tweet') do
      response = get '/twitter/retrieve_tweets_for_handle', { :screen_name => "dhh" }
    end

    Rails::logger.debug response.inspect

    puts response
    assert_select "div"

    assert_response :success
  end

end
