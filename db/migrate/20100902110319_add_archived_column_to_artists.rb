class AddArchivedColumnToArtists < ActiveRecord::Migration
  def self.up
    add_column :artists, :archived, :boolean, :default => false
    add_index :artists, [:user_id, :archived]
    add_index :artists, [:user_id, :archived, :sort_name]
  end

  def self.down
    remove_column :artists, :archived
    remove_index :artists, [:user_id, :archived]
    remove_index :artists, [:user_id, :archived, :sort_name]
  end
end
