class AddScrobbledAtColumnToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :scrobbled_at, :datetime
    add_index :tracks, :scrobbled_at
  end

  def self.down
    remove_column :tracks, :scrobbled_at
  end
end
