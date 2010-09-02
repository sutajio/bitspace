class AddDescriptionColumnToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :description, :text
  end

  def self.down
    remove_column :releases, :description
  end
end
