function TwitterViewModel()
{
  var self = this;

  self.twitter_handle = ko.observable('');
}

ko.applyBindings(new TwitterViewModel());