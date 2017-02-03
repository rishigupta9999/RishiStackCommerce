function TwitterViewModel()
{
  var self = this;

  self.twitter_handle = ko.observable('');
  self.tweets = ko.observableArray()
  self.retrievingTweets = ko.observable(false);

  self.current_screen_name = null;

  self.retrieveTweets = function()
  {
    self.retrieveTweetsHelper(true);
  }

  self.retrieveTweetsHelper = function(updatePushState)
  {
    self.tweets.removeAll();
    self.retrievingTweets(true);

    self.current_screen_name = self.twitter_handle();

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

        tweetInfo = {
                      "text" : links_added,
                    };

        self.tweets.push(tweetInfo)
      }

      self.retrievingTweets(false);
    });
  }

  window.addEventListener('popstate', function(event) {
    self.twitter_handle(event.state);
    self.retrieveTweetsHelper(false);
  });

}


$(document).ready(function(){
  ko.applyBindings(new TwitterViewModel());
});