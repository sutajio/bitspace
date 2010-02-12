class AddTagsColumnToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :tags, :string
  end

  def self.down
    remove_column :releases, :tags
  end
end
