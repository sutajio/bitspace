class AddCatalogNumberToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :catalog_number, :string
  end

  def self.down
    remove_column :releases, :catalog_number
  end
end
