require 'open-uri'
require 'base64'
require 'twitter/twitter_client'

class TwitterController < ApplicationController


  def view_tweet
    @twitter_handle = params[:twitter_handle]
  end

  def retrieve_tweets_for_handle
  
    connection_info = ::TwitterClient.create_connection

    bearer_token = connection_info[:token]
    conn = connection_info[:connection]

    screen_name = params["screen_name"]
    last_tweet_id = params["last_tweet_id"]

    #parsed_response = Rails.cache.fetch("tweet-#{screen_name}-#{last_tweet_id}", expires_in: 5.minutes) do

      url_arg = "screen_name=#{screen_name}&count=25"

      if (last_tweet_id != "0")
        url_arg += "&max_id=#{last_tweet_id}"
      end

      response = conn.get do |req|
        req.url "/1.1/statuses/user_timeline.json?#{url_arg}"
        req.headers['Authorization'] = "Bearer #{bearer_token}"
      end

      parsed_response = JSON.parse(response.body)
    #end

    render json: parsed_response

  end

end
