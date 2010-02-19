class UpdateCounterCacheForReleasesOnLabels < ActiveRecord::Migration
  def self.up
    Label.all.each do |label|
      Label.update_counters label.id, :releases_count => label.releases.count
    end
  end

  def self.down
  end
end
