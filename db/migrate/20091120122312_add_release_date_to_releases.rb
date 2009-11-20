class AddReleaseDateToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :release_date, :date
  end

  def self.down
    remove_column :releases, :release_date
  end
end
