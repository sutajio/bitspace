class AddAvatarToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string    :avatar_file_name
      t.string    :avatar_content_type
      t.integer   :avatar_file_size
      t.timestamp :avatar_updated_at
      t.integer   :avatar_width
      t.integer   :avatar_height
    end
  end

  def self.down
    remove_column :avatar_file_name
    remove_column :avatar_content_type
    remove_column :avatar_file_size
    remove_column :avatar_updated_at
    remove_column :avatar_width
    remove_column :avatar_height
  end
end
