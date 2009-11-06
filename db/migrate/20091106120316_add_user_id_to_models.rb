class AddUserIdToModels < ActiveRecord::Migration
  def self.up
    add_column :artists, :user_id, :integer
    add_column :releases, :user_id, :integer
    add_column :tracks, :user_id, :integer
    add_column :labels, :user_id, :integer
    add_index :artists, :user_id
    add_index :releases, :user_id
    add_index :tracks, :user_id
    add_index :labels, :user_id
  end

  def self.down
    remove_column :artists, :user_id
    remove_column :releases, :user_id
    remove_column :tracks, :user_id
    remove_column :labels, :user_id
  end
end
