class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.belongs_to :release
      t.belongs_to :artist
      t.string :fingerprint
      t.string :mbid
      t.string :title
      t.integer :track_nr
      t.integer :length
      t.integer :size
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
