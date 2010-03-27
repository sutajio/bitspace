class RenameTypeFields < ActiveRecord::Migration
  def self.up
    rename_column :artists, :type, :artist_type
    rename_column :labels, :type, :label_type
  end

  def self.down
    rename_column :artists, :artist_type, :type
    rename_column :labels, :label_type, :type
  end
end
