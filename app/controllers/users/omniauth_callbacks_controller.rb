class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    @user = User.from_omniauth(request.env["omniauth.auth"])    

    if @user.persisted?
      sign_in(@user)
      redirect_to tweets_path, :event => :authentication
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

end
