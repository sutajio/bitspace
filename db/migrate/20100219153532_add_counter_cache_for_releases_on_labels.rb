class AddCounterCacheForReleasesOnLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :releases_count, :integer
  end

  def self.down
    remove_column :labels, :releases_count
  end
end