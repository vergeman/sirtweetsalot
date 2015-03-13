class AddAttemptsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :attempts, :integer, default: 0
  end
end
