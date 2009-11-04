class ReCreateUsers < ActiveRecord::Migration
  def self.up
    drop_table :users
    create_table :users do |t|
      t.integer :facebook_uid
      t.string :name
      t.string :email
      t.string :persistence_token
      t.string :single_access_token
      t.string :perishable_token
      t.integer :login_count, :default => 0
      t.integer :failed_login_count, :default => 0
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip
      t.boolean :is_admin
      t.string :subscription_id
      t.string :subscription_plan, :default => User::SUBSCRIPTION_PLANS[:free][:name]
      t.decimal :max_storage, :precision => 20, :scale => 0, :default => User::SUBSCRIPTION_PLANS[:free][:storage]
      t.timestamps
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
