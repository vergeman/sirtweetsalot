class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :rememberable, :trackable
  devise :omniauthable, :omniauth_providers => [:twitter]

  has_many :tweets #, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.attributes = auth.info.to_hash.slice(*User.attribute_names)

      user.image_url = auth.info.image
      user.password = Devise.friendly_token[0,20]
      #TODO: encrypt 2-way w/ app secret
      user.token = auth.credentials.token
      user.secret = auth.credentials.secret

    end
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
      #config.access_token        = current_user.token
      #config.access_token_secret = current_user.secret
      config.access_token        = self.token
      config.access_token_secret = self.secret      
    end

    client
  end
end

