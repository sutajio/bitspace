class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.belongs_to :user
      t.string :email
      t.string :token
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
