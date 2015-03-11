class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    #EXAMPLE
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in(@user)
      redirect_to user_path(@user), :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to root_path
    end
  end

end
