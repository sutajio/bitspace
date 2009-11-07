class AddSetNrToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :set_nr, :integer
  end

  def self.down
    remove_column :tracks, :set_nr
  end
end
