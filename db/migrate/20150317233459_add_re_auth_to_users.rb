class AddReAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reauth, :boolean, default: false
  end
end
