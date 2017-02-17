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

    oauth_consumer_key = ENV['TWITTER_API_KEY']
    oauth_nonce = self.nonce
    oauth_signature_method = 'HMAC-SHA1'
    oauth_timestamp = Time.now.to_i.to_s
    oauth_token = current_user.token
    oauth_version = "1.0"

    byebug

    parameters = 'oauth_consumer_key=' +
              oauth_consumer_key +
              '&oauth_nonce=' +
              oauth_nonce +
              '&oauth_signature_method=' +
              oauth_signature_method +
              '&oauth_timestamp=' +
              oauth_timestamp +
              '&oauth_token=' +
              oauth_token + 
              '&oauth_version=' +
              oauth_version

    url = "https://api.twitter.com//1.1/direct_messages.json"
    base_string = 'GET&' + CGI.escape(url) + '&' + CGI.escape(parameters)
    signing_key = CGI.escape(ENV['TWITTER_API_SECRET']) + "&" + CGI.escape(current_user.secret)

    oauth_signature = CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',signing_key, base_string)}").chomp)

    SimpleOAuth::Header.new('GET', url, @options, @client.credentials.merge(ignore_extra_keys: true))

    response = conn.post do |req|
      req.url '/1.1/direct_messages.json'
      req.headers['oauth_consumer_key'] = oauth_consumer_key
      req.headers['oauth_nonce'] = oauth_nonce
      req.headers['oauth_signature_method'] = oauth_signature_method
      req.headers['oauth_timestamp'] = oauth_timestamp
      req.headers['oauth_token'] = oauth_token
      req.headers['oauth_version'] = oauth_version
      req.headers['oauth_signature'] = oauth_signature
    end

    byebug

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
