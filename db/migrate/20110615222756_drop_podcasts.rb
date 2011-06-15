class DropPodcasts < ActiveRecord::Migration
  def self.up
    drop_table :podcasts
  end

  def self.down
  end
end
