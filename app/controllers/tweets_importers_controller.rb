class TweetsImportersController < ApplicationController
  before_filter :authenticate_user!, :verify_settings, :needs_reauth

  #/uploads/new
  def new
    #upload mechanic
    @tweets_importer = TweetsImporter.new
  end

  #handles upload and parses
  def create
    @tweets_importer = TweetsImporter.new

    render :new and return unless has_timezone?

    begin
      @tweets_importer = TweetsImporter.new(upload_params)

      error_rows = @tweets_importer.load || []

      flash[:success] = "Tweets Successfully Imported" if error_rows.count <= 0
      flash[:alert] = "Errors loading rows: #{format_errors(error_rows)}" if error_rows.count > 0

      redirect_to queue_path

    rescue => e

      flash[:error] = "We've encountered an error: #{e.message}"

      redirect_to new_tweets_importer_path
    end

  end


  private

  def has_timezone?
    if current_user.timezone.blank?
      flash.now[:alert] = "You need to set your timezone before importing"
      return false
    end
    return true
  end

  def format_errors(error_rows)
    error_rows.join(',').scan(/(\d+)+/).join(', ')
  end

  def upload_params
    params.require(:tweets_importer).permit(:file).merge(current_user: current_user)
  end
end
