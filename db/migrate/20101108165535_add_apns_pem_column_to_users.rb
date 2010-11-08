class AddApnsPemColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :apns_pem, :text
  end

  def self.down
    remove_column :users, :apns_pem
  end
end
