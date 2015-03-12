class Tweet < ActiveRecord::Base
  belongs_to :user

  scope :sent, -> { where.not(sent_at: nil) }
  scope :sendable, -> { where(sent_at: nil) }

  #make async
  def deliver

    begin
      client = self.user.twitter_client
      response = client.update!(self.content)

      self.sent_at = client.status(response.id).created_at
      self.tweet_id = response.id
      self.save

    rescue => e
      errors.add(:tweet, e)
    end

  end

end
