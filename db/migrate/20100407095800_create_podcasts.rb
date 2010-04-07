class CreatePodcasts < ActiveRecord::Migration
  def self.up
    create_table :podcasts do |t|
      t.belongs_to :user
      t.string :url
      t.datetime :last_check_at
      t.timestamps
    end
  end

  def self.down
    drop_table :podcasts
  end
end
