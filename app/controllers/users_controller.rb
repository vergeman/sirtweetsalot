class UsersController < ApplicationController
  before_filter :authenticate_user!, :verify_settings, :needs_reauth

  #user profile stuff, account setup
  def show
  end


  def edit
  end

  def update
    @user = User.find(current_user)
    if @user.update(user_params)
      flash[:success] = "User settings updated"
      redirect_to edit_account_path
    else
      flash.now[:error] = "Error updating settings"
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:timezone, :email)
  end
end
