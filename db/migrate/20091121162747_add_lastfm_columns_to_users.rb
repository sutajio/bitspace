class AddLastfmColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lastfm_session_key, :string
    add_column :users, :lastfm_username, :string
    add_column :users, :lastfm_subscriber, :boolean
  end

  def self.down
    remove_column :users, :lastfm_session_key
    remove_column :users, :lastfm_username
    remove_column :users, :lastfm_subscriber
  end
end
