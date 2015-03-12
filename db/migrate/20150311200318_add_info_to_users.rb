class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string
    add_column :users, :name, :string
    add_column :users, :location, :string
    add_column :users, :image_url, :string
    add_column :users, :description, :string
    add_column :users, :token, :string
    add_column :users, :secret, :string
  end
end
