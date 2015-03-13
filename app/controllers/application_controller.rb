class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new_session_path(scope)
    new_user_session_path
  end

  def verify_settings
    flash.now[:alert] = view_context.link_to "You need to set your timezone", edit_account_path(current_user) if current_user.timezone.blank?
  end

end
