class Tweet < ActiveRecord::Base
  class RateLimited < StandardError; end

  belongs_to :user

  scope :sent, -> { where.not(sent_at: nil) }
  scope :sendable, -> { where(sent_at: nil) }

  #accessors views
  def scheduled_for_time
    local_time(self.scheduled_for)
  end

  def sent_at_time
    local_time(self.sent_at)
  end

  #conversion input str -> utc
  def time_to_utc
    self.scheduled_for = ActiveSupport::TimeZone
      .new(self.user.timezone)
      .local_to_utc(self.scheduled_for)
  end

  #if task status goes awry, we reset to pristine condition
  def reset
    self.update_attributes(status: "QUEUED",
                           rescheduled_at: nil,
                           tweet_id: nil,
                           sent_at: nil)
  end

  #Async Task (DJ)
  #Check the state - is it something to retry?
  #But if we're rate-limited, we'll retry . . . only later
  def deliver

    begin      
      if !rate_limited? && retry?

        client = self.user.twitter_client
        response = client.update!(self.content)

        #quick test
        #rate_limit = {'x-rate-limit-reset' => (Time.now + 3.seconds).to_i}
        #error = Twitter::Error.new("RateLimited", rate_limit)
        #raise Twitter::Error::TooManyRequests, error

        #SUCCESS
        self.update_attributes(sent_at: client.status(response.id).created_at,
                               tweet_id: response.id,
                               rescheduled_at: nil,
                               status = "SENT")
      end

    rescue => e
      errors.add(:tweet, e)
      handle_error(e)      
    end

  end


  def retry?
    #cases that will not be retried
    return !["FAIL", "DUPLICATE", "SENT"].include?(self.status)
  end


  private

  def local_time(_time)
    ActiveSupport::TimeZone
      .new(self.user.timezone)
      .parse(_time.to_s).strftime("%m-%d-%y %I:%M %p")
  end

  #error handler
  def handle_error(error)
    Delayed::Worker.logger.debug "ERRROR"
    Delayed::Worker.logger.debug error.inspect
    
    case error

    when Twitter::Error::DuplicateStatus
      Delayed::Worker.logger.debug "==Duplicate=="

      #FAIL
      self.update_attributes(rescheduled_at: nil, status: "DUPLICATE")

    when Twitter::Error::TooManyRequests,
      Twitter::Error::Forbidden,
      RateLimited

      Delayed::Worker.logger.debug "==Twitter Rate Limit=="

      #Now rate limited
      #Handle errors in Tweet model, want access to error object
      #with appropriate time value
      set_rate_limited(error.rate_limit.reset_in + 1, true)

      #quick test
      #set_rate_limited((Time.now + 3.seconds).to_i, true)

    else

      #SOME UNKNOWN ERROR
      Delayed::Worker.logger.debug "==Some error=="
      Delayed::Worker.logger.debug exception.inspect
      raise UnknownException, error
    end

  end

  def rate_limited?
    limited_until_time = self.user.rate_limited_until

    #never limited, or was once limited but that time has passed
    return false if (limited_until_time.nil? || limited_until_time < DateTime.now.utc)

    #update tweet status to rate limited
    set_rate_limited(limited_until_time, false)
    true
  end

  #updates tweet rescheduled_at time 
  #to match user rate_limited_until time
  def set_rate_limited(time, new_time_value = true)

    self.user.update_attribute(:rate_limited_until, Time.at(time).utc ) if new_time_value

    self.update_attributes(rescheduled_at: Time.at(time).utc,
                           status: "RATELIMITED")
  end

end
