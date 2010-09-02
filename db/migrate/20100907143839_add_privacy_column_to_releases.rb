class AddPrivacyColumnToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :privacy, :string, :default => 'private'
  end

  def self.down
    remove_column :releases, :privacy
  end
end
