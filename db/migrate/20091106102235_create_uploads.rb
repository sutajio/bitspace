class CreateUploads < ActiveRecord::Migration
  def self.up
    create_table :uploads do |t|
      t.belongs_to :user
      t.string :bucket
      t.string :key
      t.timestamps
    end
  end

  def self.down
    drop_table :uploads
  end
end
