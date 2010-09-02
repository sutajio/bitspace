class AddReleaseTypeColumnToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :release_type, :string
  end

  def self.down
    remove_column :releases, :release_type
  end
end
