class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.belongs_to :user
      t.belongs_to :commented, :polymorphic => true
      t.text :body
      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, [:commented_id, :commented_type]
  end

  def self.down
    drop_table :comments
  end
end
