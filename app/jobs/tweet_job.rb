class TweetJob < ActiveJob::Base


  def perform(tweet)
    log("JOB: Tweet id: #{tweet.id} | #{tweet.inspect}")
    tweet.deliver
  end


  after_perform do |job|

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

  #breaks error corrrectino on import
  #rescue_from(ActiveRecord::NotFound) do |exception|
  #  Delayed::Job.find(self).destroy
  #end


  private
  def log(text)
    Delayed::Worker.logger.debug(text)
  end

end
