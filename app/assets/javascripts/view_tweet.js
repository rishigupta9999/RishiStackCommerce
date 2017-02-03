function TwitterViewModel()
{
  var self = this;

  self.twitter_handle = ko.observable('');
  self.tweets = ko.observableArray()
  self.retrievingTweets = ko.observable(false);

  self.retrieveTweets = function()
  {
    self.tweets.removeAll();
    self.retrievingTweets(true);

    $.get("/twitter/retrieve_tweets_for_handle", { "screen_name" : self.twitter_handle() }, function(data) {

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
}

$(document).ready(function(){
  ko.applyBindings(new TwitterViewModel());
});