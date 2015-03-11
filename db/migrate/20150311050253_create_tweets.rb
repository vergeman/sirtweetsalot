class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.belongs_to :user, index: true
      t.string :content
      t.datetime :scheduled_for, null: false
      t.datetime :sent_at

      t.timestamps null: false
    end
  end
end
