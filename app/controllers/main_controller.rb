class MainController < ApplicationController
  before_filter :check_authenticated_user

  #landing page
  def index
    render :index, layout: "splash"
  end
 

  private
  def check_authenticated_user
    redirect_to tweets_path if user_signed_in?
  end

end
