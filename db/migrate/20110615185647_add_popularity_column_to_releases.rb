class AddPopularityColumnToReleases < ActiveRecord::Migration
  def self.up
    add_column :releases, :popularity, :integer, :default => 0
    add_index :releases, :popularity
    Release.find(:all, :conditions => 'original_id IS NOT NULL').each do |r|
      r.original.increment!(:popularity)
    end
  end

  def self.down
    remove_column :releases, :popularity
  end
end
