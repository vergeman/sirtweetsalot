class AddRateLimitedUntilToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rate_limited_until, :datetime
  end
end
