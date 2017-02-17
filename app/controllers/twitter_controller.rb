require 'open-uri'
require 'base64'
require 'cgi'
require 'openssl'

class TwitterController < ApplicationController

  def nonce
    rand(10 ** 30).to_s.rjust(30,'0')
  end

  def generate_signature
    puts CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}\n"))
  end

  def create_connection
    encoded_key = URI::encode(ENV["TWITTER_API_KEY"])
    encoded_secret = URI::encode(ENV["TWITTER_API_SECRET"])
    bearer_credentials = "#{encoded_key}:#{encoded_secret}"

    bearer_credentials_base64 = Base64.strict_encode64(bearer_credentials)

    conn = Faraday.new(:url => 'https://api.twitter.com') do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    access_token = Rails.cache.fetch("access_token", expires_in: 5.minutes) do

      response = conn.post do |req|
        req.url '/oauth2/token'
        req.headers['Authorization'] = "Basic #{bearer_credentials_base64}"
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
        req.body = 'grant_type=client_credentials'
      end

      parsed_response = JSON.parse(response.body)
      access_token = parsed_response["access_token"]
    end

    url = "https://api.twitter.com/1.1/account/settings.json"

    credentials = {
        consumer_key: ENV['TWITTER_API_KEY'],
        consumer_secret: ENV['TWITTER_API_SECRET'],
        token: current_user.token,
        token_secret: current_user.secret
      }

    foo = SimpleOAuth::Header.new('GET', url, {}, credentials.merge(ignore_extra_keys: true))

    response = conn.get do |req|
      req.url '/1.1/account/settings.json'
      req.headers['Authorization'] = foo.to_s
    end

    puts response.body

    return {token: access_token, connection: conn}
  end

  def view_tweet
    
  end

  def retrieve_tweets_for_handle    
    connection_info = create_connection

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
