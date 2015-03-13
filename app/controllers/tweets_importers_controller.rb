class TweetsImportersController < ApplicationController
  before_filter :authenticate_user!, :verify_settings

  #/uploads/new
  def new
    #upload mechanic
    @tweets_importer = TweetsImporter.new
  end

  #handles upload and parses
  def create
    @tweets_importer = TweetsImporter.new(upload_params)

    #prob be delayed_job - need some error handling
    error_rows = @tweets_importer.load

    flash[:success] = "Tweets Successfully Imported" if error_rows.count <= 0
    flash[:alert] = "Errors loading rows: #{format_errors(error_rows)}" if error_rows.count > 0

    redirect_to queue_path
  end


  private

  def format_errors(error_rows)
    error_rows.join(',').scan(/(\d+)+/).join(', ')
  end

  def upload_params
    params.require(:tweets_importer).permit(:file).merge(current_user: current_user)
  end
end
