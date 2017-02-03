function TwitterViewModel()
{
  var self = this;

  self.twitterHandle = ko.observable('');
  self.tweets = ko.observableArray()
  self.retrievingTweets = ko.observable(false);

  self.current_screen_name = null;

  window.gotoMention = function(event)
  {
    mention_name = event.attributes.getNamedItem("mention-name").value.slice(1);
    self.twitterHandle(mention_name);
    self.retrieveTweetsHelper(true);
  }

  self.retrieveTweets = function()
  {
    self.retrieveTweetsHelper(true);
  }

  self.retrieveTweetsHelper = function(updatePushState)
  {
    self.tweets.removeAll();
    self.retrievingTweets(true);

    self.current_screen_name = self.twitterHandle();

    if (updatePushState)
    {
      history.pushState(self.current_screen_name, null, null);
    }

    $.get("/twitter/retrieve_tweets_for_handle", { "screen_name" : self.current_screen_name }, function(data) {

      for (cur_tweet in data)
      {
        text = data[cur_tweet].text;

        links_added = URI.withinString(text, function(url) {
          return "<a target=\"_blank\" href=\"" + url + "\">" + url + "</a>";
        });

        mentions_parsed = links_added.replace(/[@]+[A-Za-z0-9-_]+/g, function(mention) {
          
          return "<a href=\"javascript:void(0)\" onclick=\"gotoMention(this)\" mention-name=\"" + mention + "\">" + mention + "\</a>";
        });

        tweet_info = {
                      "text" : mentions_parsed,
                    };

        self.tweets.push(tweet_info)
      }

      self.retrievingTweets(false);
    });
  }

  window.addEventListener('popstate', function(event) {
    self.twitterHandle(event.state);
    self.retrieveTweetsHelper(false);
  });

}


$(document).ready(function(){
  ko.applyBindings(new TwitterViewModel());
});