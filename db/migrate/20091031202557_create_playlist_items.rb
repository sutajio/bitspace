class CreatePlaylistItems < ActiveRecord::Migration
  def self.up
    create_table :playlist_items do |t|
      t.belongs_to :playlist
      t.belongs_to :user
      t.belongs_to :track
      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_items
  end
end
