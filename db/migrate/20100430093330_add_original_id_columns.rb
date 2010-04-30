class AddOriginalIdColumns < ActiveRecord::Migration
  def self.up
    add_column :artists, :original_id, :integer
    add_column :releases, :original_id, :integer
    add_column :tracks, :original_id, :integer
    add_index :artists, :original_id
    add_index :releases, :original_id
    add_index :tracks, :original_id
  end

  def self.down
    remove_column :artists, :original_id
    remove_column :releases, :original_id
    remove_column :tracks, :original_id
  end
end
