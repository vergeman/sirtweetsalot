class TweetsController < ApplicationController
  before_filter :authenticate_user!, :verify_settings

  #before_filter :editable?, only: [:edit, :update]

#aux routes
  def queue
    @tweets = current_user.tweets.sendable(order_params)
    render :index
  end

  def sent
    @tweets = current_user.tweets.sent(order_params)
    render :index
  end

#dashboard
  def index
    load_dashboard
    render :dashboard
  end

#editable tweets
  def edit
    @tweet = current_user.tweets.find_by_id(params[:id])
  end

  def update
    @tweet = current_user.tweets.find_by_id(params[:id])
    @tweet.reset if reset_params

    if @tweet.update_attributes(update_params)     
      redirect_to edit_tweet_path
    else
      render :edit
    end

  end

  def destroy
    @tweet = current_user.tweets.find_by_id(params[:id])
    if @tweet.destroy
      flash[:success] = "Tweet successfully deleted"
    else
      flash[:error] = "There was an error attempting to delete your tweet"
    end
    redirect_to :back
  end

  def destroy_multiple
    if current_user.tweets.destroy(params[:tweets])
      flash[:success] = "Tweets Deleted"
    else
      flash[:alert] = "There was a problem deleting your tweets"
    end
    redirect_to :back
  end

  private

  def load_dashboard
    #defaults

    @tstart = valid_date(params[:tstart]) || DateTime.now.utc
    @tend = valid_date(params[:tend]) || DateTime.now.utc + 7.days

    @qstart = valid_date(params[:qstart]) || DateTime.now.utc
    @qend = valid_date(params[:qend]) || DateTime.now.utc + 7.days

    @next_tweet = current_user.next_scheduled_tweet(@qstart)
    @next_tweet_time = current_user.next_scheduled_tweet_time(@qstart)

  end

  def valid_date(p)
    begin
      #make sure to convert date params to UTC
      return DateTime.parse(Time.parse(p).utc.to_s)
    rescue
      return false
    end
  end

  def update_params
    params.require(:tweet).except!(:reset).permit!
  end

  def reset_params
    params[:tweet][:reset] == 1
  end

  def order_params    
    p = params[:order].to_s.reverse.split('_') #id_asc
    p_key_val = Hash[p.each_slice(2).to_a] #{id => asc}

    valid_sort_order = p_key_val.keys.any? { |k| ["asc", "desc"].include?(k.reverse) }
    valid_attribute = Tweet.new.attributes.keys.any? { |k| k.include?(k) }

    if  valid_sort_order && valid_attribute
      params[:order].to_s.reverse.sub('_', ' ').reverse
    end
  end

  def editable?
    @tweet = current_user.tweets.find_by_id(params[:id] || params[:tweet][:id])
    if @tweet.status == "SENT"
      redirect_to tweets_path
    end

  end
end
