class AddArtworkDimensionsToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :artwork_width, :integer
    add_column :labels, :artwork_height, :integer
  end

  def self.down
    remove_column :labels, :artwork_width
    remove_column :labels, :artwork_height
  end
end
