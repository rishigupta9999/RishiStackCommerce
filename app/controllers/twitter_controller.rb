require 'open-uri'
require 'base64'

class TwitterController < ApplicationController

  def create_connection
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

    parsed_response = JSON.parse(response.body)
    access_token = parsed_response["access_token"]

    return {token: access_token, connection: conn}
  end

  def view_tweet
    
  end

  def retrieve_tweets_for_handle    
    connection_info = create_connection

    bearer_token = connection_info[:token]
    conn = connection_info[:connection]

    response = conn.get do |req|
      req.url "/1.1/statuses/user_timeline.json?screen_name=#{params["screen_name"]}&count=25"
      req.headers['Authorization'] = "Bearer #{bearer_token}"
    end

    render json: JSON.parse(response.body)

  end

end
