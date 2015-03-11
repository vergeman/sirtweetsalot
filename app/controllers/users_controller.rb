class UsersController < ApplicationController
  before_filter :authenticate_user!

  #user profile stuff, account setup
  def show
  end

end
