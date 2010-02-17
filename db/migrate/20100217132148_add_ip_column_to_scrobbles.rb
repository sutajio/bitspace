class AddIpColumnToScrobbles < ActiveRecord::Migration
  def self.up
    add_column :scrobbles, :ip, :string
  end

  def self.down
    remove_column :scrobbles, :ip
  end
end
