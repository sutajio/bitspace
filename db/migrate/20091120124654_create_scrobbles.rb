class CreateScrobbles < ActiveRecord::Migration
  def self.up
    create_table :scrobbles do |t|
      t.belongs_to :user
      t.belongs_to :track
      t.datetime :started_playing
    end
  end

  def self.down
    drop_table :scrobbles
  end
end
