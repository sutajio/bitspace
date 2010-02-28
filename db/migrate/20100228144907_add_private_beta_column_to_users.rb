class AddPrivateBetaColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :private_beta, :boolean
  end

  def self.down
    remove_column :users, :private_beta
  end
end
