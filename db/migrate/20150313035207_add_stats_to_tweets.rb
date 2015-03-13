class AddStatsToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :status, :string
    add_column :tweets, :rescheduled_at, :datetime
  end
end
