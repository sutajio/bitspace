class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.belongs_to :user
      t.belongs_to :subscriber
      t.string :subscription_id
      t.timestamps
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :subscriber_id
  end

  def self.down
    drop_table :subscriptions
  end
end
