class UsersController < ApplicationController
  before_filter :authenticate_user!

  #user profile stuff, account setup
  def show
  end

#TODO (timezone - should be 'campaign based')
  def edit
  end

  def update
  end

end
