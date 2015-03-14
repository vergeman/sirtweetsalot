require 'csv'

class TweetsImporter
  #factory class to generate Tweets
  include ActiveModel::Model

  attr_accessor :file, :current_user

  #TODO: 140char check
  def load
    tweets = load_sheet    

    #save to queue
    tweets.each_with_index do |t, index| 

      begin

        t.status = "QUEUED"
        TweetJob.set(queue: t.user_id, wait_until: t.scheduled_for).perform_later(t) if t.save!

      rescue => e
        t.errors.add(:row,"#{index+2}")
      end
    end

    #return any errors, agnostic as to their type
    tweets.map{|t| t.errors.full_messages[0]}.compact!

  end

  #loop & parse
  def load_sheet
    spreadsheet = open_sheet
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      tweet = Tweet.new(user_id: current_user.id)
      tweet.attributes = row.to_hash.slice(*Tweet.attribute_names)
      tweet.time_to_utc
      tweet

    end
  end

  #determine csv/xls, return obj  
  #TODO: random file name 
  def open_sheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    #when ".xls" then Excel.new(file.path, nil, :ignore)
    #when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end



end
