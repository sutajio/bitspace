class AddCounterCacheForTracksOnReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :tracks_count, :integer
    Release.all.each do |release|
      Release.update_counters release.id, :tracks_count => release.tracks.count
    end
  end

  def self.down
    remove_column :releases, :tracks_count
  end
end
