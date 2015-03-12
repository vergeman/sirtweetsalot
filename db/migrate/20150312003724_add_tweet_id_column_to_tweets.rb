class AddTweetIdColumnToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :tweet_id, :string
    add_index :tweets, :tweet_id
  end
end
