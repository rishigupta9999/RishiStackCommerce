# Rishi Stack Commerce Project

## Live version
See http://rishi-stack-commerce.herokuapp.com

## Setup

### Prequisites

1. PostgreSQL.  I use the version here https://postgresapp.com/
2. Redis.  Homebrew is fine `brew install redis`
3. Rails 5 using your favorite installation method.

### Installation
1. Clone this repo
2. `bundle install`
3. `rake db:create:all`
4. `rake db:migrate`

> Note: The database is used only for Devise.

### Running
1. (Optional) Start Redis with `redis-server`.  You will need to set your `ENV['REDIS_URL']` environment variable.  Without Redis the app will not fail, but no caching will be used.
2. Set `ENV['TWITTER_API_KEY']` and `ENV['TWITTER_API_SECRET']` to the appropriate values.
3. `rails s`

## Overview

### Authentication
[Devise](https://github.com/plataformatec/devise) is used for User authentication.  It is a pretty standard usage, no additional options such as e-mail confirmation or anything are being used.  Some basic tests are done to validate that devise is working.

### Calling Twitter
In the spirit of the assignment, since it seems you want to see if we can call a REST API without any "help", I'm just using Faraday to call the Twitter REST endpoints directly.

All logic is in `twitter_controller.rb` - and the only things done here are retrieving the bearer token for App Authentication on Twitter, and calling the endpoint for retrieving the user timeline.  This is returned as JSON to the front-end where the bulk of the rendering is done.

There is very little server side rendering except for using the Rails flash for showing Devise messages.  More on this below.

### Front End
The front-end uses Knockout and there is only one view (other than the Devise views).

The view roughly functions as follows:
1. Upon form submission, submits Ajax GET request to Rails back-end.
2. Progress indicator is displayed until response received.
3. Upon receiving response, JSON is parsed and necessary info is added to the Knockout observable.
4. View gets updated as per the appropriate Knockout bindings.

When a different Twitter Screen Name is followed, or you click on a *@mention*, new tweets are received.  Since `history.pushState` is used, you can still use the forward/back buttons in your browser.

In the interests of time, I did *not* implement Hash based navigation.  Just pushState.

### Testing
You can run tests with `rake test`.  Minitest is used.  [VCR](https://github.com/vcr/vcr) is used to mock the HTTP calls.  The testing checks the following.

1. Devise login allows one to access the main "View Tweet" page.
2. Lack of login denies this access.
3. Calling the endpoint for retrieving the user timeline JSON is successful.  A few basic sanity checks are performed on this data.

The front end doesn't have tests.  Time permitting I could use Jasmine or similar.


### Caching
`redis-rails` is used for caching.  Redis isn't being called directly with the raw get/set APIs, rather it's used as a Rails cache store and the standard Rails caching APIs are used.

All values in the cache (auth token and tweet requests) are cached for 5 minutes.  If you are running locally, you can observe this with `redis-cli` and look at the `TTL` as well as observe the key values with `GET` - or just observe every request after your first one being much faster since there is no need to retrieve the bearer token again.  And requests to a prior Twitter screen name are almost instantaneous.
