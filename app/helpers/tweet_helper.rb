module TweetHelper

  def format_time(tweet_time)
    tweet_time.nil? ? "-" : tweet_time.strftime("%l:%M %p")
  end

  def next_tweet_date(tweet_time)
    return "" if tweet_time.nil?
    tweet_time.today? ? "Today" : tweet_time.strftime("%b %d")
  end

# dashboard graphs helpers to build js x/y values
  def build_dates(sdate, edate)
    (sdate.utc.to_i..edate.utc.end_of_day.to_i)
      .step(1.day)
      .map{ |d| Time.at(d).strftime("%Y-%m-%d") }.join('", "').html_safe
  end

  def build_data(states, sdate, edate, attr="schedule")
    (sdate.to_i..edate.end_of_day.to_i)
      .step(1.day)
      .map{ |d|
      current_user.tweets.num_status_since(states, Time.at(d).beginning_of_day, Time.at(d).end_of_day, attr)
    }.join(',')
  end



  #status color
  def status_class(status)
    case status
    when "SENT", "QUEUED"
      "status-good"
    when "DELAYED"
      "status-poor"
    else
      "status-fail"
    end
  end

end
