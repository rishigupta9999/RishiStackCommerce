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

    parsed_response = Rails.cache.fetch("tweet-#{screen_name}", expires_in: 5.minutes) do

      puts "Tweet cache miss"

      response = conn.get do |req|
        req.url "/1.1/statuses/user_timeline.json?screen_name=#{screen_name}&count=25"
        req.headers['Authorization'] = "Bearer #{bearer_token}"
      end

      parsed_response = JSON.parse(response.body)
    end

    render json: parsed_response

  end

end
