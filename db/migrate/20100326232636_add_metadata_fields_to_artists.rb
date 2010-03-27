class AddMetadataFieldsToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :sort_name, :string
    add_column :artists, :type, :string
    add_column :artists, :begin_date, :date
    add_column :artists, :end_date, :date
    add_column :artists, :website, :string
    add_column :artists, :tags, :string
  end

  def self.down
    remove_column :artists, :sort_name
    remove_column :artists, :type
    remove_column :artists, :begin_date
    remove_column :artists, :end_date
    remove_column :artists, :website
    remove_column :artists, :tags
  end
end
