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

var cloud = d3.layout.cloud;

var fill = d3.scale.category20();

var layout = cloud()
    .size([500, 500])
    .words([
      "Hello", "world", "normally", "you", "want", "more", "words",
      "than", "this"].map(function(d) {
      return {text: d, size: 10 + Math.random() * 90, test: "haha"};
    }))
    .padding(5)
    .rotate(function() { return ~~(Math.random() * 1) * 90; })
    .font("Impact")
    .fontSize(function(d) { return d.size; })
    .on("end", draw);

layout.start();

function draw(words) {
  d3.select("body").append("svg")
      .attr("width", layout.size()[0])
      .attr("height", layout.size()[1])
    .append("g")
      .attr("transform", "translate(" + layout.size()[0] / 2 + "," + layout.size()[1] / 2 + ")")
    .selectAll("text")
      .data(words)
    .enter().append("text")
      .style("font-size", function(d) { return d.size + "px"; })
      .style("font-family", "Impact")
      .style("fill", function(d, i) { return '#000'; })
      .attr("text-anchor", "middle")
      .attr("transform", function(d) {
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      })
      .text(function(d) { return d.text; });
}