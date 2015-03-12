class TweetsImportersController < ApplicationController
  before_filter :authenticate_user!

  #/uploads/new
  def new
    #upload mechanic
    @tweets_importer = TweetsImporter.new
  end

  #handles upload and parses
  def create
    @tweets_importer = TweetsImporter.new(upload_params)

    #prob be delayed_job
    @tweets_importer.load

    redirect_to tweets_path
  end


  private
  def upload_params
    params.require(:tweets_importer).permit(:file).merge(current_user: current_user)
  end
end
