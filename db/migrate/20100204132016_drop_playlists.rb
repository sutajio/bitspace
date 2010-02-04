class DropPlaylists < ActiveRecord::Migration
  def self.up
    drop_table :playlists
  end

  def self.down
    create_table :playlists do |t|
      t.string :name
      t.timestamps
    end
  end
end
