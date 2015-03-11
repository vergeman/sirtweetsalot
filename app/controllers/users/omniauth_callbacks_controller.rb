class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    #EXAMPLE
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    puts request.env["omniauth.auth"]
    
    #missing template error,
    #need to redirect someplace

    #render :html => request.env["omniauth.auth"]
    #this needs to be slightly changed
=begin
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
=end
  end

end
