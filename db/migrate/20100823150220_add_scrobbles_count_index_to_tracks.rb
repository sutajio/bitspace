class AddScrobblesCountIndexToTracks < ActiveRecord::Migration
  def self.up
    add_index :tracks, :scrobbles_count
  end

  def self.down
    remove_index :tracks, :scrobbles_count
  end
end
