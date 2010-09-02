class AddArchivedColumnToLabels < ActiveRecord::Migration
  def self.up
    add_column :labels, :archived, :boolean, :default => false
    add_index :labels, [:user_id, :archived]
    add_index :labels, [:user_id, :archived, :sort_name]
  end

  def self.down
    remove_column :labels, :archived
    remove_index :labels, [:user_id, :archived]
    remove_index :labels, [:user_id, :archived, :sort_name]
  end
end
