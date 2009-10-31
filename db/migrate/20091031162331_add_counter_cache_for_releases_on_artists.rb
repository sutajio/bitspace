class AddCounterCacheForReleasesOnArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :releases_count, :integer
    Artist.all.each do |artist|
      Artist.update_counters artist.id, :releases_count => artist.releases.count
    end
  end

  def self.down
    remove_column :artists, :releases_count
  end
end
