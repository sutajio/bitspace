class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.belongs_to :user
      t.string :apns_token
      t.timestamps
    end
    add_index :devices, :user_id
  end

  def self.down
    drop_table :devices
  end
end
