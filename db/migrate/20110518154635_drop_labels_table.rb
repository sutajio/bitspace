class DropLabelsTable < ActiveRecord::Migration
  def self.up
    drop_table :labels
  end

  def self.down
  end
end
