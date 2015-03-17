#[FAILED, DUPLICATE, SENT] - not sendable states (end states)
#[QUEUED, DELAYED] - sendable
#
#there can be sent tweets that are 'finished', won't be requeued
#Handled api erros
# RateLimit / TooManyRequests
# Duplicate ---> not actually finished, just very long delay
# ?

class Tweet < ActiveRecord::Base
  class RateLimited < StandardError; end

  belongs_to :user, inverse_of: :tweets

  SENT_STATES = ["FAILED", "DUPLICATE", "SENT"]
  SENDING_STATES = ["QUEUED", "DELAYED"]

  scope :sent, ->(var_order) { where.not(status: SENDING_STATES).order('?', var_order)  }
  scope :sendable, ->(var_order) { where.not(status: SENT_STATES).order('?', var_order) }
  scope :num_queued, -> (from = Time.now.utc, to = (Time.now.utc + 7.days)) { where(status: SENDING_STATES).select{|t| t.schedule.between?(from, to)}.count }

#QUICK QUEUE
  scope :next_scheduled, -> (since = Time.now.utc) { where(status: SENDING_STATES).min_by{|t| since <=> t.schedule} }

#TWEETOMETER
  scope :percentage_since, -> (status, start_date, end_date) {
    (num_status_since(status, start_date, end_date).to_f / num_all_normalized(status, start_date, end_date) * 100)
  }

  #fix for :percentage_since div by 0
  scope :num_all_normalized, -> (status, start_date, end_date) {
    num_status_since(SENT_STATES + SENDING_STATES, start_date, end_date) == 0 ? 1.to_f : num_status_since(SENT_STATES + SENDING_STATES, start_date, end_date) 
  }

  scope :status_since, -> (status, start_date, end_date) { where(status: status).select{|t| t.schedule.between?(start_date, end_date) } }

  scope :num_status_since, -> (status, start_date, end_date) { status_since(status, start_date, end_date).count }

  def schedule
    self.rescheduled_at.nil? ? self.scheduled_for : self.rescheduled_at
  end

  #accessors views
  def scheduled_for_time
    local_time(self.scheduled_for)
  end

  def sent_at_time
    local_time(self.sent_at)
  end

  #conversion input str -> utc
  def scheduled_for_time_to_utc
    self.scheduled_for = ActiveSupport::TimeZone
      .new(self.user.timezone)
      .local_to_utc(self.scheduled_for)
  end


  #if task status goes awry, we reset to pristine condition
  def reset
    self.update_attributes(status: "QUEUED",
                           rescheduled_at: nil,
                           sent_at: nil,
                           tweet_id: nil)

    TweetJob.set(queue: self.user_id,
                 wait_until: self.scheduled_for).perform_later(self)
  end

  #Async Task (DJ)
  #Check the state - is it something to retry?
  #But if we're rate-limited, we'll retry . . . only later
  def deliver

    begin      
      if !rate_limited? && retry?

        client = self.user.twitter_client
        self.increment!(:attempts, 1)
        response = client.update!(self.content)

        #quick test
        #rate_limit = {'x-rate-limit-reset' => (Time.now + 3.seconds).to_i}
        #error = Twitter::Error.new("RateLimited", rate_limit)
        #raise Twitter::Error::TooManyRequests, error

        #SUCCESS
        self.update_attributes(sent_at: client.status(response.id).created_at,
                               tweet_id: response.id,
                               rescheduled_at: nil,
                               status: "SENT")
      end

    rescue => e
      errors.add(:tweet, e)
      handle_error(e)      
    end

  end


  def retry?
    #cases that will not be retried
    return !SENT_STATES.include?(self.status)
  end


  private

  def local_time(_time)
    ActiveSupport::TimeZone
      .new(self.user.timezone)
      .parse(_time.to_s).strftime("%m-%d-%y %I:%M %p")
  end

  #error handler
  def handle_error(error)
    Delayed::Worker.logger.debug "ERROR"
    Delayed::Worker.logger.debug error.inspect
    
    case error

    when Twitter::Error::DuplicateStatus
      Delayed::Worker.logger.debug "==Duplicate=="

      #FAIL
      self.update_attributes(rescheduled_at: nil,
                             status: "DUPLICATE",
                             sent_at: Time.now.utc)

    when Twitter::Error::TooManyRequests,
      Twitter::Error::Forbidden,
      RateLimited

      Delayed::Worker.logger.debug "==Twitter Rate Limit=="

      #Now rate limited
      #Handle errors in Tweet model, want access to error object
      #with appropriate time value

      rate_limit_reset = (Time.now + 5.minutes).to_i
      if defined?(error.rate_limit.reset_in)
        rate_limit_reset = error.rate_limit.reset_in || rate_limit_reset
      end
      
      set_rate_limited(rate_limit_reset + 1, true)



    else

      #SOME UNKNOWN ERROR
      Delayed::Worker.logger.debug "==Unspecified error=="
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
                           status: "DELAYED",
                           sent_at: Time.now.utc)
  end

end
