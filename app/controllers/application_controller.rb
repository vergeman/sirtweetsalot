class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(scope)
    new_user_session_path
  end

  def verify_settings
    flash.now[:alert] = view_context.link_to "You need to set your timezone. Please update your Settings.", edit_account_path(current_user) if current_user.timezone.blank?
  end

  def needs_reauth

    if current_user && current_user.reauth
      flash.now[:alert] = "You'll need to login again to reauthorize Sir Tweets-A-Lot"

      current_user.update_attribute(:reauth, false)
      sign_out(current_user)
      redirect_to(root_path)
    end
  end

end
