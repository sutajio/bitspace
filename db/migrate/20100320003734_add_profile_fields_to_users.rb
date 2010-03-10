class AddProfileFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :public_profile, :boolean, :default => true
    add_column :users, :biography, :string
  end

  def self.down
    remove_column :users, :public_profile
    remove_column :users, :biography
  end
end
