class AddLovedColumnToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :loved_at, :datetime
  end

  def self.down
    remove_column :tracks, :loved_at
  end
end
