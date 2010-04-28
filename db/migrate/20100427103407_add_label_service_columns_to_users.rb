class AddLabelServiceColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribable, :boolean
    add_column :users, :subscription_price, :integer
    add_column :users, :subscription_currency, :string
    add_column :users, :subscription_periodicity, :string
  end

  def self.down
    remove_column :users, :subscribable
    remove_column :users, :subscription_price
    remove_column :users, :subscription_currency
    remove_column :users, :subscription_periodicity
  end
end
