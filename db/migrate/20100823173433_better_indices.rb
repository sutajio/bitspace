class BetterIndices < ActiveRecord::Migration
  def self.up
    add_index :tracks, [:user_id, :loved_at]
    add_index :tracks, [:user_id, :scrobbles_count]
    add_index :tracks, [:user_id, :scrobbled_at]
    add_index :tracks, [:user_id, :created_at]
  end

  def self.down
    remove_index :tracks, [:user_id, :loved_at]
    remove_index :tracks, [:user_id, :scrobbles_count]
    remove_index :tracks, [:user_id, :scrobbled_at]
    remove_index :tracks, [:user_id, :created_at]
  end
end
