class AddGeolocationToScrobbles < ActiveRecord::Migration
  def self.up
    add_column :scrobbles, :country, :string
    add_column :scrobbles, :city, :string
    add_column :scrobbles, :latitude, :float
    add_column :scrobbles, :longitude, :float
  end

  def self.down
    remove_column :scrobbles, :country
    remove_column :scrobbles, :city
    remove_column :scrobbles, :latitude
    remove_column :scrobbles, :longitude
  end
end
