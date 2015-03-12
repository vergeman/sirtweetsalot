require 'csv'

class TweetsImporter
  #factory class to generate Tweets
  include ActiveModel::Model

  attr_accessor :file, :current_user

  #TODO: 140char check
  def load
    tweets = load_sheet    
    if tweets.map(&:valid?).all?
      tweets.each(&:save!)
      true
    else
      tweets.each_with_index do |tweet, index|
        tweet.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  #loop & parse
  def load_sheet
    spreadsheet = open_sheet
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      tweet = Tweet.new(user_id: current_user.id)
      tweet.attributes = row.to_hash.slice(*Tweet.attribute_names)
      tweet

    end
  end

  #determine csv/xls, return obj  
  def open_sheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    #when ".xls" then Excel.new(file.path, nil, :ignore)
    #when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end



end
