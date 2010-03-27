class AddArtworkDimensionsToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :artwork_width, :integer
    add_column :artists, :artwork_height, :integer
  end

  def self.down
    remove_column :artists, :artwork_width
    remove_column :artists, :artwork_height
  end
end
