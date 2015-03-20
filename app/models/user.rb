require 'aes'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :omniauthable, :omniauth_providers => [:twitter]

  has_many :tweets, inverse_of: :user #, dependent: :destroy

  def self.from_omniauth(auth)

    #user = where(provider: auth.provider, uid: auth.uid).first    
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.attributes = auth.info.to_hash.slice(*User.attribute_names)
      user.image_url = auth.info.image
      user.password = Devise.friendly_token[0,20]
    end
    puts user.inspect

    self.update_credentials(user, auth)
    puts user.inspect

    return user
  end

  def self.key
    Rails.application.secrets.secret_key_base
  end

  def self.update_credentials(user, auth)
    user.update_attributes(token: AES.encrypt(auth.credentials.token, User.key),
                           secret: AES.encrypt(auth.credentials.secret, User.key),
                           reauth: false)
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.twitter_data"] && session["devise.twitter_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def twitter_client

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_API_KEY']
      config.consumer_secret     = ENV['TWITTER_API_SECRET']

      config.access_token        = AES.decrypt(self.token, User.key)
      config.access_token_secret = AES.decrypt(self.secret, User.key )
    end

    client
  end


#model based  
  def next_scheduled_tweet_time(from, to)
    tweet = self.tweets.scheduled_between(from, to).min_by(&:schedule)
    tweet.nil? ? nil : tweet.schedule.in_time_zone(self.timezone)
  end

  def next_scheduled_tweet(from, to)
    tweets.scheduled_between(from, to).min_by(&:schedule)
  end


end

