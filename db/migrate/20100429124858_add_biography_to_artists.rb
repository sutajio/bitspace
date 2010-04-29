class AddBiographyToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :biography, :text
  end

  def self.down
    remove_column :artists, :biography
  end
end
