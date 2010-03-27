class AddIndicesToSortNameFields < ActiveRecord::Migration
  def self.up
    add_index :artists, :sort_name
    add_index :labels, :sort_name
  end

  def self.down
    remove_index :artists, :sort_name
    remove_index :labels, :sort_name
  end
end
