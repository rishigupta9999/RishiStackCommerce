# Rishi Stack Commerce Project

## Setup

### Prequisites

1. PostgreSQL.  I use the version here https://postgresapp.com/
2. Redis.  Homebrew is fine `brew install redis`
3. Rails 5 using your favorite method.

### Installation
1. Clone this repo
2. `bundle install`
3. `rake db:create:all`
4. `rake db:migrate`

> Note: The database is used only for Devise.

### Running
1. (Optional) Start Redis with `redis-server`.  You will need to set your `ENV['REDIS_URL']` environment variable.
2.

## Overview

### Authentication
[Devise](https://github.com/plataformatec/devise) is used for User authentication.  It is a pretty standard usage, no additional options such as e-mail confirmation or anything are being used.  Some basic tests are done to validate that devise is working.

### Calling Twitter
In the spirit of the assignment, since it seems you want to see if we can call a REST API without any "help", I'm just using Faraday to call the Twitter REST endpoints directly.

All logic is in `twitter_controller.rb` - and the only things done here are retrieving the bearer token for App Authentication on Twitter, and calling the endpoint for retrieving the user timeline.  This is returned as JSON to the front-end where the bulk of the rendering is done.

There is very little server side rendering except for using the Rails flash for showing Devise messages.  More on this below.

### Front End

### Testing
