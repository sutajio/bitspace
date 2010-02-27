class UpdateCounterCacheForScrobblesOnTracks < ActiveRecord::Migration
  def self.up
    Track.find_each do |track|
      Track.update_counters track.id, :scrobbles_count => track.scrobbles.count
    end
  end

  def self.down
  end
end
