require 'open-uri'
require 'base64'

class TwitterController < ApplicationController
  def view_tweet
    encoded_key = URI::encode(ENV["twitter_api_key"])
    encoded_secret = URI::encode(ENV["twitter_api_secret"])
    bearer_credentials = "#{encoded_key}:#{encoded_secret}"

    bearer_credentials_base64 = Base64.strict_encode64(bearer_credentials)

    conn = Faraday.new(:url => 'https://api.twitter.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.post do |req|
      req.url '/oauth2/token'
      req.headers['Authorization'] = "Basic #{bearer_credentials_base64}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
      req.body = 'grant_type=client_credentials'
    end

    puts response.body
  end
end
