class TweetsController < ApplicationController
  before_filter :authenticate_user!

#aux routes
  def queue
    @tweets = current_user.tweets.sendable    
    render :index
  end

  def sent
    @tweets = current_user.tweets.sent
    render :index
  end

#dashboard
  def index
    @tweets = Tweet.all
    render :dashboard
  end

#editable tweets
  def edit
  end

  def update
  end

  def destroy
  end

#testing route
  def launch
    @tweet = Tweet.find_by_id(params[:id])
    @tweet.deliver
    render :show
  end
  #timezone - scheduled time vs server time relative
end
