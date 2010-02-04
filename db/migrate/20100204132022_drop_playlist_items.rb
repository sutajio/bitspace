class DropPlaylistItems < ActiveRecord::Migration
  def self.up
    drop_table :playlist_items
  end

  def self.down
    create_table :playlist_items do |t|
      t.belongs_to :playlist
      t.belongs_to :user
      t.belongs_to :track
      t.timestamps
    end
  end
end
