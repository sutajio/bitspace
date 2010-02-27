class AddTimezoneToScrobbles < ActiveRecord::Migration
  def self.up
    add_column :scrobbles, :time_zone, :string
  end

  def self.down
    remove_column :scrobbles, :time_zone
  end
end
