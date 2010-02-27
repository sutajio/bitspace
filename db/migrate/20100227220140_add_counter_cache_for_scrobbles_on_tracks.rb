class AddCounterCacheForScrobblesOnTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :scrobbles_count, :integer
  end

  def self.down
    remove_column :tracks, :scrobbles_count
  end
end
