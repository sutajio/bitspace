class AddScrobbleToLastfmColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :scrobble_to_lastfm, :boolean, :default => true
  end

  def self.down
    remove_column :users, :scrobble_to_lastfm
  end
end
