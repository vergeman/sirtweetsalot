class TweetsController < ApplicationController
  before_filter :authenticate_user!, :verify_settings

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
    TweetJob.set(queue: @tweet.user.id, wait_until: @tweet.scheduled_for).perform_later(@tweet)
    @tweet.deliver
    render :show
  end

end
