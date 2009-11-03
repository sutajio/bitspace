class AddSubscriptionFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_plan, :string, :default => 'Bitspace Free'
    add_column :users, :max_storage, :integer, :default => 1.gigabyte
  end

  def self.down
    remove_column :users, :subscription_plan
    remove_column :users, :max_storage
  end
end
