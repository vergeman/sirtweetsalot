class TweetJob < ActiveJob::Base

  def perform(tweet)
    log("==DELIVER==")
    tweet.deliver
  end

  after_perform do |job|
    log("==AFTER_PERFORM==")
    tweet = job.arguments.first

    #retry logic
    if !tweet.rescheduled_at.nil? && tweet.retry?
      retry_job(queue: tweet.user.id,
                wait_until: tweet.rescheduled_at)
      log("Retrying Tweet #{tweet.id}: #{tweet.rescheduled_at}")
    end

  end

  rescue_from(Exception) do |exception|
    log(exception.inspect)
    #self.arguments.first.inspect)
  end  


    private
    def log(text)
      Delayed::Worker.logger.debug(text)
    end

end
