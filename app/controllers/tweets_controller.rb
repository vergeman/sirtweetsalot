class TweetsController < ApplicationController
  before_filter :authenticate_user!, :verify_settings, :needs_reauth

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
    @tweet.reset && redirect_to(queue_path) and return if reset_params

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

    @qstart = valid_date(params[:qstart], "beginning_of_day") || valid_date(Time.now.to_s, "beginning_of_day")
    @qend = valid_date(params[:qend], "end_of_day") || valid_date( (Time.now + 7.days).to_s, "end_of_day")

    @tstart = valid_date(params[:tstart], "beginning_of_day") || valid_date( (Time.now - 7.days).to_s, "beginning_of_day")
    @tend = valid_date(params[:tend], "end_of_day") || valid_date( Time.now.to_s, "end_of_day")

    @next_tweet = current_user.next_scheduled_tweet(@qstart, @qend)
    @next_tweet_time = current_user.next_scheduled_tweet_time(@qstart, @qend)

  end

  def valid_date(p, of_day)
    begin
      return DateTime.parse(Time.parse(p).send(of_day).to_s)
    rescue
      return false
    end
  end

  def update_params
    params.require(:tweet).except!(:reset).permit!
  end

  def reset_params
    params[:tweet][:reset] == 1.to_s
  end

  def order_params
    p = params[:order].to_s.split('_')
    sort_order = valid_order(p)

    sort_attribute = params[:order].to_s.dup
    sort_attribute.slice!("_#{sort_order}")

    return "#{sort_attribute} #{sort_order}" if !sort_order.nil? && valid_attribute(sort_attribute)
  end

  def valid_order(p)
    ["asc", "desc"].select{|w| w == p.last }.first
  end

  def valid_attribute(sort_attribute)
    ["id", "content", "scheduled_for", "sent_at", "status", "rescheduled_at"].include?(sort_attribute)
  end

  def editable?
    @tweet = current_user.tweets.find_by_id(params[:id] || params[:tweet][:id])
    if @tweet.status == "SENT"
      redirect_to tweets_path
    end

  end
end
