module TweetHelper

  def format_time(tweet_time)
    tweet_time.nil? ? "-" : tweet_time.strftime("%l:%M %p")
  end

  def next_tweet_date(tweet_time)
    return "" if tweet_time.nil?
    tweet_time.today? ? "Today" : tweet_time.strftime("%b %d")
  end

end
