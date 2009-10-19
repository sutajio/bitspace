class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.belongs_to :artist
      t.belongs_to :label
      t.string :mbid
      t.string :title
      t.integer :year
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :releases
  end
end
