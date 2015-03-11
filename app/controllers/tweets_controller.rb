class TweetsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @tweets = Tweet.all
    #create scopes by scheduled / sent
    #upload mechanic
  end

  #edit|update / destroy tweets

  #create - will be upload? - don't necessarily want to persist csv file

  #timezone - scheduled time vs server time relative
end
